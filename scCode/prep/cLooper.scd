~cLooper = {
	arg inBus, id=0, outBus=0, numChan=2, lag=1.0, bufDur=300, server;
	var isRec, isPlaying, recBuffer, bus;
	var recLev = 1.0, preLev = 0.0;
	var oscFunc, recorder, loopPlayer;
	var loopDur;
	var prep = { 
		forkIfNeeded { 
			isRec = false;
			isPlaying = false;
			server = server ? Server.default;
			recBuffer = Buffer.alloc(server, server.sampleRate * bufDur, numChan);
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
				arg in=0, buf=0, id=0, recLev=1.0, preLev=0.0, t_trig=0;
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
					loopPlayer = Synth.after(recorder, \loopPlayer, [
						\out, outBus,
						\bufnum, recBuffer,
						\atk, 1,
						\rel, 6,
						\amp, 1,
						\gate, 1,
						\rate, 1.0,
						\lag, lag,
						\loopDur, 10;
					]);
					loopPlayer.set(\loopDur, loopDur);
					"Set loop dur to ".post; loopDur.postln;
					server.sendBundle(lag, recorder.freeMsg );
					isPlaying = true;
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
		loopPlayer.set(\gate, 0);
		isPlaying = false;
		
	};

	var toggleRec = {
		isPlaying.not.if({
			isRec.if({
				recorder.set(\t_trig, 1.0);
				\TstoppingRec.postln;
				isRec = false;
			},{
				recorder = Synth.tail(server, \loopRecorder, [
					\in, inBus,
					\buf, recBuffer,
					\id, id,
					\recLev, recLev,
					\preLev, preLev
				]);
				isRec = true;
				\TstartingRec.postln;
			})
		},{
			"Can't record loop while playing".postln;
		});
	};


	var freeMe = {
		recBuffer.free;
		recorder.free;
		loopPlayer.free;
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
		recBuffer: { recBuffer },
		bus: { bus },
		loopDur: { loopDur },
		prep: { prep.value },
		toggleRec: { toggleRec.value },
		stopPlayback: { stopPlayback.value },
		freeMe: { freeMe.value }
	);
}
