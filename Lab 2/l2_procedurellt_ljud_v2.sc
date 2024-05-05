// Starta servern
s.boot; // en rad kod körs med <Shift> och <Enter>
// Stop server
s.quit;
// Start oscilloscope
s.scope;


// När servern är igång skickar man över en eller flera synth definitioner till serven.
// Kod inom parenteser körs med <cmd> och <Enter> på Mac eller <ctrl> och <Enter> i Windows

// Bass drum
(
var outlvl = 0.15;

SynthDef(\bassDrum, { arg t_trig = 1;
	var body, hit, output;

	body = SinOsc.ar(50);
	body = body * EnvGen.ar(Env.perc(0, 0.3, 2, -4), t_trig);

	hit = LFPar.ar(250);
	hit = hit * EnvGen.ar(Env.perc(0, 0.07, 1, -4), t_trig);

	output = (0.6*hit) + 2*body;
	output = output *0.3;

	Out.ar(0, {output*outlvl}!2);
}).play;



// Snare drum

SynthDef(\snareDrum, { arg t_trig = 1;
	var freq, body, noise, output;

	freq = 220;
	body = SinOsc.ar(freq) + (SinOsc.ar(freq)*0.10);
	body = body * EnvGen.ar(Env.perc(0, 0.1, 1, -4), t_trig);

	noise = WhiteNoise.ar(0.25);
	noise = HPF.ar(noise, 600);
	noise = noise * EnvGen.ar(Env.perc(0, 0.15), t_trig);

	output = body + noise;
	output = output *0.5;

	Out.ar(0, {output*outlvl}!2);
}).play;


// ClHiHat

SynthDef(\clHiHat, { arg t_trig = 1;
	var noise, tones, output;

	noise = WhiteNoise.ar(0.25);
	tones = LFPulse.ar(1700, width: 0.5) + LFPulse.ar(1150, width: 0.5) + LFPulse.ar(820, width: 0.5) + LFPulse.ar(465, width: 0.5);
	tones = tones/4;
	tones = tones *EnvGen.ar(Env.perc(0.005, 1, 1, -8));
	noise = noise + (tones/3);

	noise = HPF.ar(noise, 13000);
	noise = noise * EnvGen.ar(Env.perc(0.005, 0.2, 2, -3), t_trig);

	output = noise;
	output = output *0.5;

	Out.ar(0, {output*outlvl}!2);

}).play;


// OpHiHat

SynthDef(\opHiHat, { arg t_trig = 1;
	var noise, tones, output;

	noise = WhiteNoise.ar(0.25);
	tones = LFPulse.ar(1600, width: 0.5) + LFPulse.ar(950, width: 0.5) + LFPulse.ar(620, width: 0.5) + LFPulse.ar(265, width: 0.5);
	tones = tones/4.5;
	noise = noise / 1.5 + tones;

	noise = HPF.ar(noise, 4000);
	noise = noise * EnvGen.ar(Env.perc(0.005, 0.45, 1.5, -1), t_trig);

	output = noise;
	output = output *0.5;

	Out.ar(0, {output*outlvl}!2);

}).play;


// High tom

SynthDef(\highTom, { arg t_trig = 1;
	var body, pitchEnvelope, output;

	pitchEnvelope = EnvGen.ar(Env.perc(0, 0.5, 2, -4), t_trig).range(1, 2);
	body = SinOsc.ar(80 * pitchEnvelope);
	body = body * EnvGen.ar(Env.perc(0, 0.5, 1.5, -4), t_trig);

	output = body;

	output = output *0.4;

	Out.ar(0, {output*outlvl}!2);

}).play;


// Low tom

SynthDef(\lowTom, { arg t_trig = 1;
	var body, pitchEnvelope, output;

	pitchEnvelope = EnvGen.ar(Env.perc(0, 0.1, 2, -4), t_trig).range(1, 6);
	body = SinOsc.ar(30 * pitchEnvelope);
	body = body * EnvGen.ar(Env.perc(0, 0.5, 1.5, -4), t_trig);

	output = body;
	output = output *0.4;

	Out.ar(0, {output*outlvl}!2);

}).play;


// fun sound
// Woodblock

SynthDef(\woodBlock, { arg t_trig = 1;
	var body, pitchEnvelope, output, body1, body2;

	body1 = SinOsc.ar(450);
	body2 = SinOsc.ar(150);
	body = body1+body2;
	output = body * EnvGen.ar(Env.perc(0, 0.2, 1, -8), t_trig);
	output =output*0.25;

	Out.ar(0, {output*outlvl}!2);

}).play;


// fun sound
// Cowbell

SynthDef(\cowBell, { arg t_trig = 1;
	var output;
	var lfo = LFPulse.kr(10).range(0, 1);
	output = (LFPulse.ar(540, width: 0.5)* EnvGen.ar(Env.perc(0, 0.5, 1, -4), t_trig)) + (LFPulse.ar(800, width: 0.5)*EnvGen.ar(Env.perc(0, 0.5, 1, -4), t_trig));
	output = output*0.07;

	Out.ar(0, {output*outlvl*lfo}!2);

}).play;


// Crash

SynthDef(\crash, { arg t_trig = 1;
	var noise, tones, output;

	noise = WhiteNoise.ar(0.25);
	tones = LFPulse.ar(2000, width: 0.5) + LFPulse.ar(1150, width: 0.5) + LFPulse.ar(820, width: 0.5) + LFPulse.ar(465, width: 0.5);
	tones = tones/4;
	noise = noise + tones;

	noise = RHPF.ar(noise, 4000, 0.7);
	noise = noise * EnvGen.ar(Env.perc(0.005, 3, 1, -8), t_trig);

	output = noise;
	output = output *0.5;

	Out.ar(0, {output*outlvl}!2);
}).play;
)



// test
