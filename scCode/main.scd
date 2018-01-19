// Stop playback in harmo modes: does it work?
(
{
	~rppFilePath = "../quintetMix/quintetMix.RPP".resolveRelative;
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
	s.sync;
	// ~ipsPrefix = "192.168.1.";
	// ~ips = (14..18);
	// ~ipsPrefix = "192.168.109.";
	// ~ips = (97..101);
	~ipsPrefix = "10.42.0.";
	~ips = [191];
	~transpose = 0;
	~sponges = IdentityDictionary.new();
	~voices = IdentityDictionary.new();

	~ips.do({ |i, j|
		// var sym = ("sponge_" ++ i.asAscii).asSymbol;
		var sym = ("sponge_" ++ i).asSymbol;
		~sponges.put( sym, ~cSponge.value( ~ipsPrefix ++ i, sym, Server.default ) );
		~sponges[sym].prep;
		s.sync;
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
				popId: j + 210,
				relTime: 10.0,
				server: s
		));
		///////////////
		s.sync;
		~voices.at(sym).do({|i| i.prep});
		s.sync;
		sym.post; " ready.".postln;
	});
	s.sync;
	
	"jack_connect SuperCollider:out_1  REAPER:in1
	 jack_connect SuperCollider:out_2   REAPER:in2
	 jack_connect SuperCollider:out_3   REAPER:in3
	 jack_connect SuperCollider:out_4   REAPER:in4
	 jack_connect SuperCollider:out_5   REAPER:in5
	 jack_connect SuperCollider:out_6   REAPER:in6
	 jack_connect SuperCollider:out_7   REAPER:in7
	 jack_connect SuperCollider:out_8   REAPER:in8
	 jack_connect SuperCollider:out_9   REAPER:in9
	 jack_connect SuperCollider:out_10  REAPER:in10
     jack_connect SuperCollider:out_11  REAPER:in11
     jack_connect SuperCollider:out_12  REAPER:in12
     jack_connect SuperCollider:out_13  REAPER:in13
     jack_connect SuperCollider:out_14  REAPER:in14
     jack_connect SuperCollider:out_15  REAPER:in15
     jack_connect SuperCollider:out_16  REAPER:in16
     jack_connect SuperCollider:out_17  REAPER:in17
     jack_connect SuperCollider:out_18  REAPER:in18
     jack_connect SuperCollider:out_19  REAPER:in19
     jack_connect SuperCollider:out_20  REAPER:in20
     jack_connect SuperCollider:out_21  REAPER:in21
     jack_connect SuperCollider:out_22  REAPER:in22
     jack_connect SuperCollider:out_23  REAPER:in23
     jack_connect SuperCollider:out_24  REAPER:in24
     jack_connect SuperCollider:out_25  REAPER:in25
     jack_connect SuperCollider:out_26  REAPER:in26
     jack_connect SuperCollider:out_27  REAPER:in27
     jack_connect SuperCollider:out_28  REAPER:in28
     jack_connect SuperCollider:out_29  REAPER:in29
     jack_connect SuperCollider:out_30  REAPER:in30

	 jack_connect REAPER:out1 system:playback_1
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

~voices[\sponge_191][1].looper.recBuffers[0].play
(~voices[\sponge_191][1].pitcher.set(\base,[ \c2, \cs2, \d2, \ds2, \en2, \fn2].keynum.midicps))
[ \gn2, \an2, \cn3, \fn2, \fn3, \dn3]
(~voices[\sponge_191][1].freqBuses.get)

(~voices[\sponge_191][0].freqBuses.get)

~sponges[\sponge_d].butts.mode.dump

191.asAscii