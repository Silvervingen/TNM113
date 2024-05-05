// Starta servern
s.boot; // en rad kod körs med <ctr> och <Enter>
// Stop server
s.quit;
// Start oscilloscope
s.scope;


// När servern är igång skickar man över en eller flera synth definitioner till serven.
// Kod inom parenteser körs med <cmd> och <Enter> på Mac eller <ctrl> och <Enter> i Windows
// viktigt att alla var är över alla aktioner.

(
SynthDef(\sweep, { arg t_trig = 1;
	// öka width, skapar känslan som att man tar helium,
	var sawtooth = LFSaw.kr(0.1, iphase: 1).range(1, 8);
	var sound = LFPulse.ar(120 * sawtooth, width: 1, mul: 0.25);

	var soundLevelMod = LFPulse.kr(32).range(0,1);
	// soundLevelMod freqvensen avgör hur snabbt beated blir
	var output = sound*soundLevelMod;

	Out.ar(0, {output}!2);
}).play;
)

(
SynthDef(\shoom, { arg t_trig = 1;
	// öka width, skapar känslan som att man tar helium,
	var sawtooth = LFSaw.kr(0.1, iphase: 1).range(1, 8);
	var sound = LFPulse.ar(120 * sawtooth, width: 1, mul: 0.25);

	// stora ljudet
	var noise = WhiteNoise.ar(0.2);
	var envelope = EnvGen.ar(Env.perc(attackTime: 0.01, releaseTime: 2, level:
		1, curve: -4.0), gate: (sawtooth - 1));
	var filteredNoise = RLPF.ar(noise, 100 + (10000 *envelope), 0.1);
	var envelopedNoise = filteredNoise * envelope;

	var reverbed;
	var output;

	output = envelopedNoise ;
	reverbed = output;

	// hur AllpassC fungerar
	//AllpassC.ar(in: 0.0, maxdelaytime: 0.2, delaytime: 0.2, decaytime: 1.0, mul: 1.0, add: 0.0)

	3.do({ reverbed = AllpassC.ar(reverbed, 0.5, 0.3, 0.66, 1, 0)}); // eko
	3.do({ reverbed = AllpassC.ar(reverbed, 0.2, { Rand(0.001,0.06) }.dup,6)}); // efterklang
	output = output + (reverbed * 0.5);

	Out.ar(0, {output}!2);
}).play;
)

// lägre a värde ger en mörkare ljud dvs a.rand. Crackle.ar(a,b) om a blir mindre så blir de ljusare men mer än 2 så blir de en kort ljud sen tyst.!3 spelas upp flera gånger men känns ljusare i ton.

(
fork{
	loop{
		play{
			Splay.ar({
				Klank.ar(`[200.rand * (1 .. 10)], Crackle.ar(2, 0.01));
			}!2) * LFGauss.ar(10, 0.25, 0, 0, 2)
		};
		1.wait;
	}

}.play;
)

(
fork{
	loop{
		h = ([34, 36, 41, 43].choose.midicps) * (2 ** ((0 .. 4).choose));
		play{
			Splay.ar({
				SinOsc.ar(exprand(h - (h / 64), h + (h / 64)), 0, 0.1)}!8) * LFGauss.ar(10,0.25, 0, 0, 2);
		};
		1.wait;
	};
};
)

(
fork{
	loop{
		h = ([34, 36, 41, 43].choose.midicps) * (2 ** ((0 .. 4).choose));
		play{
			Splay.ar({
				LFSaw.ar(exprand(h - (h / 64), h + (h / 64)), 0, 0.1)}!8) * LFGauss.ar(10,0.25, 0, 0, 2);
		};
		1.wait;
	};
};
)

(
fork{
	loop{
		h = ([34, 36, 41, 43].choose.midicps) * (2 ** ((0 .. 4).choose));
		play{
			Splay.ar({
				LFTri.ar(exprand(h - (h / 64), h + (h / 64)), 0, 0.1)}!8) * LFGauss.ar(10,0.25, 0, 0, 2);
		};
		1.wait;
	};
};
)