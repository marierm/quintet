SynthDef(\sineTest, { |freq = 1000, amp=1, t_trig=1|
	Out.ar(
		0,
		SinOsc.ar(
			freq,
			0,
			// EnvGen.ar(Env([0,0,1,1,0],[1,0,0.1,0]),t_trig, amp)));
			EnvGen.ar(Env.perc(0.0001,0.2),t_trig, amp,doneAction:2)));
}).add;


// x = Synth.tail(s, \sineTest);


~last = 0;
OSCdef(\feather,{|msg, time, address, port|
	msg.postln;
	(msg[1] != ~last).if({
		~last = msg[1];
		msg[1].postln;
		(msg[1] == 1).if({
			Synth.tail(s, \sineTest);
		});
	});
}, "/sponge", srcID: NetAddr("192.168.109.102", 50502), recvPort:50501);




~timeAvg = 0.0;
~oldTime = 100000.0;
OSCdef(\feather,3{|...msg|
	var diff;
	diff = msg[1] - ~oldTime;
	~oldTime = msg[1];
	~timeAvg = (~timeAvg + diff) * 0.5;
	~timeAvg.postln;
}, "/sponge", srcID: NetAddr("192.168.109.97", 50502), recvPort:50501);

OSCdef(\feather,{|...msg|}, "/sponge", srcID: NetAddr("192.168.109.102", 50502), recvPort:50501);

OSCdef(\feather,{|msg, time, src|
	var accXYZ, fsrAB;
	// convert to 1.5g, 10 bits.
	accXYZ = msg[1..6].collect({ |val|
		val.linlin( -24576, 24575, 0, 1023);
	});
	fsrAB = msg[7..8].collect({ |val|
		val >> 2;
	});
	(accXYZ ++ fsrAB ++ msg[11]).postln;
}, "/sponge", srcID: NetAddr("192.168.109.102", 50502), recvPort:50501);




OSCFunc.trace(false);
x.free;
x.set(\t_trig, 1);

x = SpongeFeather("/sponge", \sponge01, NetAddr("192.168.109.102", 50502), 50501);
x.free; // x.free is the same thing.
x.gui;


BP(\sponge).butts.modes[1].buttonFunctions[0].functions[0][0].asCompileString

OSCdef(\feather,{|msg, time, src|
}, "/sponge", srcID: NetAddr("192.168.109.102", 50502), recvPort:50501);


~oldVal = 0;
OSCdef(\feather,{|msg, time, src|
	var ids;
	ids = (	msg[11] bitXor: ~oldVal);
	// If at least one bit changed:
	ids.asBoolean.if({
		// msg[11].postln;
		// ids.postln;
		msg[1].class.postln;
	});
	~oldVal = msg[11];
}, "/sponge", srcID: NetAddr("192.168.109.102", 50502), recvPort:50501);


x = Array.fill(9,0);


~sponge = SpongeFeather(
	"/sponge",
	\sponge01,
	NetAddr("192.168.109.102", 50502),
	50501
);

~sponge.values[8].asBinaryDigits(10);

div(3,2)