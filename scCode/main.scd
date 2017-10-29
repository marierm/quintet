~rppFilePath = "";
"reaper5".unixCmd;
"killall jconvolver;".unixCmd;
"jconvolver -N rvb ~/docs/soundBank/ir/True\\ M7/Halls/amsterdamHall.conf".unixCmd;
s.boot;
"/home/marierm/scripts/jackDisconnectEverything.py".unixCmd;

(
{
	s.bootSync;
	"prep/sponge.scd".loadRelative;
	"prep/parents.scd".loadRelative;
	"prep/parentsFm.scd".loadRelative;
	"prep/fm.scd".loadRelative;
	s.sync;
	~sponges = IdentityDictionary.new();
	(97..101).do({ |i, j|
		var sym = ("sponge_" ++ i.asAscii).asSymbol;
		~sponges.put( sym, ~cSponge.value( "192.168.109." ++ i, sym, Server.default ) );
		~sponges[sym].prep;
		s.sync;
		~sponges[sym].sponge.hold_(true);
		PR(\fm).chuck(BP( (sym ++ 0).asSymbol ), parms:(
			interpolatorPath: ("fm0*").resolveRelative.pathMatch.sort.last.resolveRelative,
			sponge: ~sponges[sym].sponge,
			outBus: j * 2,
			notes: ([ \en1, \en2, \en3].keynum.mirror2.clump(3)).flat + (0 * 12),
			// notes: ([ \bb0, \bb1, \bb2].keynum.mirror2.clump(3)).flat + (i * 12),
			numNotes: 6,
			fmId: 20,
			fsrMuteThreshold: 0.85, // larger number = muting is easier
			chords: [
				[ \en1, \en2, \en3, \en3, \en2, \en1].keynum,
				// [ \fs7, \bn7, \en8, \en7, \bf7, \cn8].keynum - 12,
				[ \en2, \en3, \gn3, \dn4, \fs4, \bn4].keynum,
				[ \en2, \dn3, \fs3, \dn4, \fs4, \bn4].keynum,
				[ \en2, \cn3, \gn3, \dn4, \fs4, \bn4].keynum,
				[ \en2, \bn2, \an3, \dn4, \fs4, \bn4].keynum,
				[ \en2, \en3, \cn4, \dn4, \fs4, \bn4].keynum,
				[ \en2, \dn3, \gn3, \cn4, \fs4, \bn4].keynum,
				[ \en2, \cn3, \gn3, \bn3, \fs4, \bn4].keynum,
				[ \en2, \dn3, \fs3, \bn3, \en4, \an4].keynum,
				[ \fs7, \bn7, \en8, \en7, \bf7, \cn8].keynum - 48,
				[ \fn7, \bf7, \ef8, \en7, \bf7, \cn8].keynum - 48,
				[ \en7, \an7, \cs8, \ef7, \af7, \dn8].keynum - 48,
				[ \gf7, \an7, \cn8, \fn7, \af7, \df8].keynum - 48,
				[ \gf7, \an7, \cn8, \fn7, \bf7, \dn8].keynum - 48,
				[ \gf7, \an7, \cn8, \fn7, \bn7, \dn8].keynum - 48,
				[ \gn7, \an7, \cn8, \fn7, \bn7, \dn8].keynum - 48,
				[ \gn7, \an7, \cn8, \fn7, \fn8, \dn8].keynum - 48
			],
			defName: sym
		));
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
	 jack_connect REAPER:out1 system:playback_1
     jack_connect REAPER:out2 system:playback_2".unixCmd;

	"jack_connect REAPER:out7 rvb:inL
     jack_connect REAPER:out8 rvb:inR
     jack_connect rvb:outL REAPER:in13
     jack_connect rvb:outR REAPER:in14".unixCmd;

	(97..101).do({ |i|
		var sym = ("sponge_" ++ i.asAscii).asSymbol;
		~sponges[sym].sponge.hold_(false);
	});
	"prep/gui.scd".loadRelative;
	{
		a = ~quintetGui.value([100,98,97,101,99]);
		// order is francis, ana, martin, emilie, preston
		a.window.front;
	}.defer;
}.fork
)

