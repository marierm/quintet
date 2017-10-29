~cSponge = {
	arg ip, defName = \sponge01, server;
	var numBits = 5;
	// This table is used to invert the bit order of the buttons.  This is
	// useful when controling pitch with the buttons.
	var conversionTable = (0..(2.pow(numBits) - 1)).collect({|i|
		i.asInteger.asBinaryDigits(numBits).reverse.convertDigits(2)
	});
	var netAddress, sponge, butts;
	var pitchMode = 1;
	var harmoMode = 2;

	var prep = {
		server = server ? Server.default;
		ip.isNil.if({
			netAddress = nil;
		},{
			netAddress = NetAddr(ip, 50502);
		});
		server.waitForBoot({
			sponge = SpongeFeather(
				"/sponge",
				netAddress,
				50501,
				currentEnvironment // To execute the OSCfunc inside this environment.
			);
			// activate the features needed
			[
				\acc1xHP, \acc1yHP, \acc1zHP,
				\acc2xHP, \acc2yHP, \acc2zHP, 
				\acc1xBP, \acc1yBP, \acc1zBP,
				\acc2xBP, \acc2yBP, \acc2zBP, 
				\bend
			].do{|i,j|
				sponge.activateFeature(i);
			};
			// create button bank
			butts = ButtonBank(ButtonInput.sponge(sponge));
			// Buttons 9 to 5 are used to make operations on corresponding voices.
			// Modifier keys will change their behavior.
			// Level 0 stops the voice.
			// Level 1 starts the voice.
			// Level 16 (bit 4) changes to "pitch control" mode.
			// ~butts.modes[0].buttonFunctions[0..4].do{|i,j|
			butts.modes[0].buttonFunctions[9].do{|i,j|
				i.functions_( // Right hand, finger 1.
					Dictionary.newFrom([
						1, Array.newClear(32).putEach([0,1],[
							{ // When no modifier key is pressed.
								\stop.post; j.postln;
								BP( (defName ++ j).asSymbol ).stopNow;
							},
							{ //  When left hand, key 1 is held.
								\play.post; j.postln;
								BP( (defName ++ j).asSymbol ).play(0,doReset: true);
							},
						]),
						0, Array.newClear(32).putEach([8, 16],[
							{ // When left hand, key 4 is held.
								("mode harmo " + (j + 1)).postln;
								butts.mode_(j + 2);
							},
							{ // When left hand, key 5 is held.
								("mode pitch" + (j + 1)).postln;
								butts.mode_(j + 1);
							},
						])
					]);
				)
			};
			// in mode 0, buttons 0 to 4 are modifier keys.
			butts.modes[0].buttonFunctions[4..0].do{|i,j| i.makeModifier(j)};

			// In mode 1, buttons 0 to 4 sets the pitch.
			butts.newMode; // pitch mode is created
			// buttons 0 to 4 are not really modifiers.  They set the level
			// and then, the level is used to set the pitch.
			butts.modes[pitchMode].buttonFunctions[0..4].do{|i,j| i.makeModifier(j)};

			// Enable double clicks for button 9.
			butts.modes[pitchMode].buttonFunctions[9].enableNclick;

			// for each button(0 to 4), add function to level 0.
			(0..4).do{|i,j|
				butts.modes[pitchMode].buttonFunctions[i].functions[1][0] = (
					butts.modes[pitchMode].buttonFunctions[i].functions[1][0]
				).addFunc({
					// This func offsets the pitch of the voice.
					BP( (defName ++ 0).asSymbol ).pitchOsBus.set(
						conversionTable[ butts.modes[pitchMode].level ]
					);
				});
				butts.modes[pitchMode].buttonFunctions[i].functions[0][0] = (
					butts.modes[pitchMode].buttonFunctions[i].functions[0][0]
				).addFunc({
					// do it when button is released too
					BP( (defName ++ 0).asSymbol ).pitchOsBus.set(
						conversionTable[ butts.modes[pitchMode].level ]
					);
				});
			};


			// button 5 switch back to mode 0 (any level works).
			butts.modes[pitchMode].addFunc(
				button: 5,
				function: {
					butts.mode_(0);
					("mode:" + 0).postln; 
					butts.mode.level_(0);
				}.inEnvir,
				levels: (0..31),
				buttState: 1
			);

			// button 9 starts the voice.
			// Double click stops it.
			butts.modes[pitchMode].addFunc(
				button: 9,
				function: {
					\stop.post; h.postln;
					BP( (defName ++ 0).asSymbol ).stopNow;
					// \play.post; h.postln;
					// BP( (~defName ++ 0).asSymbol ).play(0,doReset: true);
				},
				levels: (0..31),
				buttState: 2
			);
			butts.modes[pitchMode].addFunc(
				button: 9,
				function: {
					\play.post; h.postln;
					BP( (defName ++ 0).asSymbol ).play(0,doReset: true);
					// \unfreeze.post; h.postln;
					// BP( (~defName ++ 0).asSymbol ).unfreezeMe;
				},
				levels: (0..31),
				buttState: 1
			);

			// button 6 (right hand, key 4) = one octave lower
			butts.modes[pitchMode].addFunc(
				button: 6,
				function: {
					\octVbStuck.post; h.postln;
					BP( (defName ++ 0).asSymbol ).octVb;
				},
				levels: (0..31),
				buttState: 1
			);

			// button 7 (right hand, key 3) one octave higher
			butts.modes[pitchMode].addFunc(
				button: 7,
				function: {
					\octVaStuck.post; h.postln;
					BP( (defName ++ 0).asSymbol ).octVa;
				},
				levels: (0..31),
				buttState: 1
			);

			// button 8 (right hand, key 2) reset octave (to octave 1)
			butts.modes[pitchMode].addFunc(
				button: 8,
				function: {
					\octReset.post; h.postln;
					BP( (defName ++ 0).asSymbol ).octReset;
				},
				levels: (0..31),
				buttState: 0
			);




			// Mode 2 is harmoMode 8, buttons 0 to 4 sets notes of chords.

			butts.newMode;
			// buttons 0 to 4 are not really modifiers.  They set the level
			// and then, the level is used to set the chord.
			butts.modes[harmoMode].buttonFunctions[0..4].do{|i,j| i.makeModifier(j)};

			butts.modes[harmoMode].buttonFunctions[9].enableNclick;
			// for each button(0 to 4), add function to level 0.
			(0..4).do{ |i,j|
				butts.modes[harmoMode].buttonFunctions[i].functions[1][0] = (
					butts.modes[harmoMode].buttonFunctions[i].functions[1][0]
				).addFunc({
					// This func offsets the pitch of the voice.
					BP( (defName ++ 0).asSymbol ).setChord(
						conversionTable[ butts.modes[harmoMode].level ]
					);
				});
				butts.modes[harmoMode].buttonFunctions[i].functions[0][0] = (
					butts.modes[harmoMode].buttonFunctions[i].functions[0][0]
				).addFunc({
					// do it when button is released too
					BP( (defName ++ 0).asSymbol ).setChord(
						conversionTable[ butts.modes[harmoMode].level ]
					);
				});
			};


			// button 5 switches back to mode 0 (any level works).
			butts.modes[harmoMode].addFunc(
				button: 5,
				function: {
					butts.mode_(0);
					("mode:" + 0).postln; 
					butts.mode.level_(0);
				}.inEnvir,
				levels: (0..31),
				buttState: 1
			);

			// button 9 starts the voice (this is for harmo mode).
			// Double click stops it (this is for harmo mode).
			butts.modes[harmoMode].addFunc(
				button: 9,
				function: {
					\stop.post; h.postln;
					BP( (defName ++ 0).asSymbol ).stopNow;
				},
				levels: (0..31),
				buttState: 2
			);
			butts.modes[harmoMode].addFunc(
				button: 9,
				function: {
					\play.post; h.postln;
					BP( (defName ++ 0).asSymbol ).play(0,doReset: true);
				},
				levels: (0..31),
				buttState: 1
			);

			// Octave controls for harmo mode.
			butts.modes[harmoMode].addFunc(
				button: 6,
				function: {
					\octVbStuck.post; h.postln;
					BP( (defName ++ 0).asSymbol ).octVb;
				},
				levels: (0..31),
				buttState: 1
			);
			butts.modes[harmoMode].addFunc(
				button: 8,
				function: {
					\octReset.post; h.postln;
					BP( (defName ++ 0).asSymbol ).octReset;
				},
				levels: (0..31),
				buttState: 0
			);
			butts.modes[harmoMode].addFunc(
				button: 7,
				function: {
					\octVaStuck.post; h.postln;
					BP( (defName ++ 0).asSymbol ).octVa;
				},
				levels: (0..31),
				buttState: 1
			);
		});
	};

	var close = {
		{ sponge.close; }.try;
	};

	(
		netAddress: { netAddress },
		sponge: { sponge },
		prep: { prep.value },
		butts: { butts },
		close: { close.value }
	);
};

// ~s1 = ~cSponge.value("192.168.109.97", Server.default);
// ~s1.prep;
// ~s1.sponge.gui


