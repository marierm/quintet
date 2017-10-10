~quintetGui = { |ips=#[100,98,97,101,99]|
	var window, spongeViews, octaveViews;
	var names = ["francis", "ana", "martin", "emilie", "preston"]; // this hardcoded
	//  array may cause problems eventually.  Sorry.  I had to make this work fast.
	var numSponges = ips.size;
	var oscFuncs;

	octaveViews = ips.collect({|i,j|
		StaticText().string_("1").align_(\center).font_(Font(nil, 250));
	});
	window = Window("Sponges", (80*numSponges)@170);
	spongeViews = names.collect({ |i,j|
		View(window, 70@120).layout_(
			VLayout(
				StaticText().string_(i).align_(\center),
				octaveViews[j]
			)
		)
	});

	window.layout_(
		HLayout(*spongeViews);
	);

	oscFuncs = ips.collect({ |ip,i|
		OSCFunc({ |msg|
			{
				octaveViews[i].string_(msg[1].asString);
			}.defer;
			msg.postln;
		}, "/sponge_" ++ ip.asAscii);
	});
	
	(
		window: { window },
		oscFuncs: { oscFuncs }
	)
	
};