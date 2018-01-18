~cLooper = {
	arg inBus, id=0, outBus=0, numChan=2, lag=1.0, bufDur=60, numLoops=16, server;
	var isRec, isPlaying, recBuffers, bus;
	var recLev = 0.9, preLev = 0.9, releaseTime=22;
	var oscFunc, recorder, loopPlayers;
	var loopDur, nextLoopId=0, task;
	var prep = { 
		forkIfNeeded {
			isRec = false;
			isPlaying = Array.fill(numLoops, { false });
			loopPlayers = Array.fill(numLoops, nil);
			server = server ? Server.default;
			recBuffers = numLoops.collect({
				Buffer.alloc(
					server, // add 1 second to allow some latency. 
					server.sampleRate * (bufDur + lag + 1.0),
					numChan
				);
			});
			SynthDef(\loopPlayer, {
				arg out=0, bufnum=0, atk=5, rel=6, amp=1, gate=0, rate=1.0, lag=1.0, loopDur=10.0;
				var sig, env;
				env = EnvGen.kr(Env.asr(atk,1,rel, curve:\sqr), gate, amp, doneAction:2);
				sig = PlayBufCF.ar(
					numChan,
					bufnum,
					BufRateScale.kr(bufnum) * rate,
					trigger: LFPulse.ar(((loopDur/rate)).reciprocal),
					lag: lag);
				Out.ar(out, sig * env);
			}).add;
			bus = Bus.audio(s, 2);
			SynthDef(\loopRecorder, {
				arg in=0, buf=0, id=0, recLev=0.9, preLev=0.9, t_trig=0;
				var phasor;
				in = In.ar(in, numChan);
				phasor = Phasor.ar(0, 1, 0, BufFrames.kr(buf));
				RecordBuf.ar(
					in,
					bufnum: buf,
					offset: 0,
					recLevel: recLev,
					preLevel: preLev,
					run: 1,
					loop: 1,
					trigger: 1,
					doneAction: 0
				);
				SendTrig.kr(t_trig, id, phasor); // send duration of loop to sclang.
			}).add;
			server.sync;
			oscFunc = OSCFunc({ |msg|
				var msgId;
				msgId = msg[2];
				(msgId == id).if({
					loopDur = msg[3] / server.sampleRate;
					loopPlayers[nextLoopId].release(0.2);
					loopPlayers[nextLoopId] = Synth.after(recorder, \loopPlayer, [
						\out, outBus,
						\bufnum, recBuffers[nextLoopId],
						\atk, 1,
						\rel, releaseTime,
						\amp, 1,
						\gate, 1,
						\rate, 1.0,
						\lag, lag
					]);
					loopPlayers[nextLoopId].set(\loopDur, loopDur);
					"Set loop dur ".post; nextLoopId.post; " to ".post; loopDur.postln;
					server.sendBundle(lag, recorder.freeMsg );
					isPlaying[nextLoopId] = true;
					nextLoopId = (nextLoopId + 1) % numLoops;
				});
			}.inEnvir, "/tr", server.addr);
			server.sync;
		};
		currentEnvironment;
	};

	// ~startRec = {
	// 	~recorder.isPlaying.not.if({
	// 		// ~loopPlayer.isPlaying.if({
	// 		// 	~recLev = 0.33;
	// 		// 	~preLev = 0.67;
	// 		// },{
	// 		// 	~recLev = 1.0;
	// 		// 	~preLev = 0.0;
	// 		// });
	// 		~recorder = Synth.tail(~server, \loopRecorder, [
	// 			\in, ~inBus,
	// 			\buf, ~recBuffer,
	// 			\id, ~id,
	// 			\recLev, ~recLev,
	// 			\preLev, ~preLev
	// 		]);
	// 		NodeWatcher.register(~recorder);
	// 	});
	// 	// ~recorder.set(\t_reset, 1.0);
	// };

	// ~stopRec = { // and start playback
	// 	~recorder.set(\t_trig, 1.0);
	// };

	var stopPlayback = {
		loopPlayers.do({ |i|
			i.set(\gate, 0);
		});
		isPlaying = Array.fill(numLoops, { false });
		server.makeBundle(releaseTime, {  
			recBuffers.do({ |buffer| // zero the buffers;
				buffer.zero
			});
		});
		nextLoopId = 0;
	};

	var toggleRec = {
		// isPlaying.not.if({
		isRec.if({
			recorder.set(\t_trig, 1.0);
			"Stop rec loop ".post; nextLoopId.postln;
			isRec = false;
			task.stop;
			task.reset;
			// task.postln;
		},{
			recorder = Synth.tail(server, \loopRecorder, [
				\in, inBus,
				\buf, recBuffers[nextLoopId],
				\id, id,
				\recLev, recLev,
				\preLev, preLev
			]);
			isRec = true;
			"Starting rec on buf ".post; nextLoopId.postln;
			// if we already recorded a loop, stop recording after
			// loopDur seconds.
			// (loopDur>0.0).if({
			// Do not record for more than bufDur seconds.
			task.stop; task.reset; // this may not be necessary.
								   // Doublec check.
			task = Task({
				bufDur.wait;
				recorder.set(\t_trig, 1.0);
				"Auto stopping loop rec.".postln;
				isRec = false;
			}).start;
			// });
		})
		// },{
		// 	"Can't record loop while playing".postln;
		// });
	};


	var freeMe = {
		recBuffers.do(_.free);
		recorder.free;
		loopPlayers.do(_.free);
		oscFunc.free;
	};

	(
		inBus: { inBus },
		id: { id },
		outBus: { outBus },
		numChan: { numChan },
		lag: { lag },
		bufDur: { bufDur },
		server: { server },
		isRec: { isRec },
		isPlaying: { isPlaying },
		recBuffers: { recBuffers },
		loopPlayers: { loopPlayers },
		bus: { bus },
		loopDur: { loopDur },
		prep: { prep.value },
		toggleRec: { toggleRec.value },
		stopPlayback: { stopPlayback.value },
		freeMe: { freeMe.value }
	);
}
