// Stop playback in harmo modes: does it work?
// Make option to stop loops in the order they appeared.
// Find a way to make inheritance.

// Pops did not stop with sponge zebra.
(
{
	~scJackName="SuperCollider:out_"; //for Jack connections
	// ~scJackName="supernova:output_"; //for Jack connections
	~reaperInJackName="REAPER:in";

	~rppFilePath = "../quintetMix/quintetMix.RPP".resolveRelative;
	// ~cond = Condition.new;
	("reaper5" + ~rppFilePath).unixCmd;
	"killall jconvolver;".unixCmd;
	0.1.wait;
	"jconvolver -N rvb ~/docs/soundBank/ir/True\\ M7/Halls/amsterdamHall.conf".unixCmd;
	s.bootSync;
	"/home/marierm/scripts/jackDisconnectEverything.py".unixCmd;
	"prep/cSponge.scd".loadRelative;
	"prep/cLooper.scd".loadRelative;
	"prep/cFm.scd".loadRelative;
	"prep/cPopperRzn.scd".loadRelative;
	"prep/cPopper.scd".loadRelative;
	"prep/cPlayer.scd".loadRelative;
	s.sync;
	1.wait;
	// ~ipsPrefix = "192.168.109.";
	// ~ips = (14..18);
	// ~ipsPrefix = "192.168.109.";
	// ~ips = [191];
	// ~ips = (97..98);
	~ipsPrefix = "10.42.0.";
	~ips = [140];
	~transpose = 0;
	~sponges = IdentityDictionary.new();
	~voices = IdentityDictionary.new();

	// x = ~cSponge.value( ~ipsPrefix ++ 97, \sponge, Server.default );
	// x.prep;
	// x.sponge.hold_(true);
	~ips.do({ |i, j|
		// var sym = ("sponge_" ++ i.asAscii).asSymbol;
		var sym = ("sponge_" ++ i).asSymbol;
		~sponges.put( sym, ~cSponge.value( ~ipsPrefix ++ i, sym, Server.default ) );
		~sponges[sym].prep;
		s.sync;
		1.wait;
		~sponges[sym].sponge.hold_(true);
		~voices.put( sym, List[] );
		~voices[sym].add( // add fm synth to voice 0 of each sponge.
			~cFmManager.value(
				interpolatorPath: ("fm0*").resolveRelative.pathMatch.sort.last.resolveRelative,
				cSponge: ~sponges[sym],
				notes: ([ \en1, \en2, \en3].keynum.mirror2.clump(3)).flat + (0 * 12) + ~transpose,
				chords: [
					[ \en1, \en2, \en3, \en3, \en2, \en1].keynum + ~transpose,
					// [ \fs7, \bn7, \en8, \en7, \bf7, \cn8].keynum - 12,
					[ \en2, \en3, \gn3, \dn4, \fs4, \bn4].keynum + ~transpose,
					[ \en2, \dn3, \fs3, \dn4, \fs4, \bn4].keynum + ~transpose,
					[ \en2, \cn3, \gn3, \dn4, \fs4, \bn4].keynum + ~transpose,
					[ \en2, \bn2, \an3, \dn4, \fs4, \bn4].keynum + ~transpose,
					[ \en2, \en3, \cn4, \dn4, \fs4, \bn4].keynum + ~transpose,
					[ \en2, \dn3, \gn3, \cn4, \fs4, \bn4].keynum + ~transpose,
					[ \en2, \cn3, \gn3, \bn3, \fs4, \bn4].keynum + ~transpose,
					[ \en2, \dn3, \fs3, \bn3, \en4, \an4].keynum + ~transpose,
					[ \fs2, \bn2, \en3, \en2, \bf2, \cn3].keynum + ~transpose,
					[ \fn2, \bf2, \ef3, \en2, \bf2, \cn3].keynum + ~transpose,
					[ \en2, \an2, \cs3, \ef2, \af2, \dn3].keynum + ~transpose,
					[ \gf2, \an2, \cn3, \fn2, \af2, \df3].keynum + ~transpose,
					[ \gf2, \an2, \cn3, \fn2, \bf2, \dn3].keynum + ~transpose,
					[ \gf2, \an2, \cn3, \fn2, \bn2, \dn3].keynum + ~transpose,
					[ \gn2, \an2, \cn3, \fn2, \bn2, \dn3].keynum + ~transpose,
					[ \gn2, \an2, \cn3, \fn2, \fn3, \dn3].keynum + ~transpose
				],
				outBus: j * 2,
				fsrMuteThreshold: 0.85, // larger number = muting is easier
				fmId: j + 20,
				relTime: 0.2,
				server: s
			)
		);
		~voices[sym].add( // add melo synth to voice 1 of each sponge.
			~cPopperRzn.value(
				interpolatorPath: ("popMelo"++1++"*").resolveRelative.pathMatch.sort.last.resolveRelative,
				cSponge: ~sponges[sym],
				notes: [ \en1, \en2, \en3, \en3, \en2, \en1].keynum + 24 + ~transpose,
				chords: [
					[ \en1, \en2, \en3, \en3, \en2, \en1].keynum + ~transpose,
					// [ \fs7, \bn7, \en8, \en7, \bf7, \cn8].keynum - 12,
					[ \en2, \en3, \gn3, \dn4, \fs4, \bn4].keynum + ~transpose,
					[ \en2, \dn3, \fs3, \dn4, \fs4, \bn4].keynum + ~transpose,
					[ \en2, \cn3, \gn3, \dn4, \fs4, \bn4].keynum + ~transpose,
					[ \en2, \bn2, \an3, \dn4, \fs4, \bn4].keynum + ~transpose,
					[ \en2, \en3, \cn4, \dn4, \fs4, \bn4].keynum + ~transpose,
					[ \en2, \dn3, \gn3, \cn4, \fs4, \bn4].keynum + ~transpose,
					[ \en2, \cn3, \gn3, \bn3, \fs4, \bn4].keynum + ~transpose,
					[ \en2, \dn3, \fs3, \bn3, \en4, \an4].keynum + ~transpose,
					[ \fs2, \bn2, \en3, \en2, \bf2, \cn3].keynum + ~transpose,
					[ \fn2, \bf2, \ef3, \en2, \bf2, \cn3].keynum + ~transpose,
					[ \en2, \an2, \cs3, \ef2, \af2, \dn3].keynum + ~transpose,
					[ \gf2, \an2, \cn3, \fn2, \af2, \df3].keynum + ~transpose,
					[ \gf2, \an2, \cn3, \fn2, \bf2, \dn3].keynum + ~transpose,
					[ \gf2, \an2, \cn3, \fn2, \bn2, \dn3].keynum + ~transpose,
					[ \gn2, \an2, \cn3, \fn2, \bn2, \dn3].keynum + ~transpose,
					[ \gn2, \an2, \cn3, \fn2, \fn3, \dn3].keynum + ~transpose
				],
				outBus: (j*4) + 10,
				tetra: false,
				fsrMuteThreshold: nil,
				rznId: j + 210,
				relTime: 10.0,
				server: s
			)
		);
		~voices[sym].add( // add melo synth to voice 1 of each sponge.
			~cPopper.value(
				interpolatorPath: ("popMelo"++1++"*").resolveRelative.pathMatch.sort.last.resolveRelative,
				cSponge: ~sponges[sym],
				notes: [ \en1 ],
				outBus: (j*4) + 10,
				tetra: false,
				amp: 4.dbamp,
				fsrMuteThreshold: nil,
				popId: j + 550,
				server: s
			)
		);
		~voices[sym].add( // add flm playback for each sponge.
			~cPlayer.value(
				audioFilePath: "samples/01-flm.wav".resolveRelative,
				cSponge: ~sponges[sym],
				outBus: (j*4) + 10,
				tetra: false,
				amp: 0.dbamp,
				attackTime: 5,
				relTime: 1,
				ampCtl: true,
				playerId: j + 880,
				server: s
			)
		);
		~voices[sym].add( // add feu playback for each sponge.
			~cPlayer.value(
				audioFilePath: "samples/05-feu.wav".resolveRelative,
				cSponge: ~sponges[sym],
				outBus: (j*4) + 10,
				tetra: false,
				amp: 0.dbamp,
				attackTime: 15,
				relTime: 12,
				ampCtl: false,
				playerId: j + 1430,
				server: s
			)
		);
		///////////////
		s.sync;
		1.wait;
		~voices.at(sym).do({|i| i.prep});
		s.sync;
		1.wait;
		sym.post; " ready.".postln;
	});
	s.sync;

	// Make Jack connections.
	(~ips.size * 6).do({ |i|
		var string;
		string = "jack_connect" + ~scJackName ++ (i+1) + ~reaperInJackName ++ (i+1);
		string.unixCmd;
	});

	"jack_connect REAPER:out1 system:playback_1
     jack_connect REAPER:out2 system:playback_2".unixCmd;
	
	"jack_connect REAPER:out7 rvb:inL
     jack_connect REAPER:out8 rvb:inR
     jack_connect rvb:outL REAPER:in31
     jack_connect rvb:outR REAPER:in32".unixCmd;

	~ips.do({ |i|
		// var sym = ("sponge_" ++ i.asAscii).asSymbol;
		var sym = ("sponge_" ++ i).asSymbol;
		~sponges[sym].sponge.hold_(false);
	});
	"prep/gui.scd".loadRelative;
	{
		// a = ~quintetGui.value([100,98,97,101,99]);
		// order is francis, ana, martin, emilie, preston
		a = ~quintetGui.value(~ips);
		a.window.front;
	}.defer;
}.fork
)

~voices[\sponge_111][0]


[1].looper.recBuffers[0].play
(~voices[\sponge_191][1].pitcher.set(\base,[ \c2, \cs2, \d2, \ds2, \en2, \fn2].keynum.midicps))
[ \gn2, \an2, \cn3, \fn2, \fn3, \dn3]
(~voices[\sponge_191][1].freqBuses.get)

~voices[\sponge_191][3].playMe;

~sponges[\sponge_d].butts.mode.dump;

~sponges[\sponge_97].sponge.hold_(true)

.butts.mode.dump;


s.sync


