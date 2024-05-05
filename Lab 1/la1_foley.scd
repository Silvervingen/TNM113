// Starta servern
s.boot; // en rad kod körs med <Shift> och <Enter>
// Stop server
s.quit;
// Start oscilloscope
s.scope;
FreqScope.new(400,200,0,server:s);

// När servern är igång skickar man över en eller flera synth definitioner till serven.
(
// Kod inom parenteser körs med <cmd> och <Enter> på Mac eller <ctrl> och <Enter> i Windows

SynthDef(\strength, { arg bufnum = 0, rateMod = 1, ampMod = 1;
	var sound = PlayBuf.ar(
		numChannels: 2,
		bufnum: bufnum,
		rate: BufRateScale.kr(bufnum)*rateMod,
		trigger: 1,
		startPos: 0,
		loop: 1, // 1: ljudet loopar
		doneAction: 0,
	);


	var output = sound*ampMod;

	var envelope2 = EnvGen.kr(Env.perc(attackTime: 0.01, releaseTime: 0.1, level: 1.0, curve: -4.0).range(100,10000));

	output = LPF.ar(output, 880); //LP/HP filtrering
	output = RLPF.ar(output, 440, rq: 0.1); //LP/HP filtrering m. resonans
	//output = BPF.ar(output, 440, rq: 0.1).range(-10,10);

	//var envelope = EnvGen.kr(Env.perc(attackTime: 0.01, releaseTime: 0.5, level: 1.0, curve: -4.0));

	//output = output*envelope;

	Out.ar(0, output);
}).add;

)




(

SynthDef(\brew, { arg bufnum = 0, rateMod = 1, ampMod = 1;
	var sound = PlayBuf.ar(
		numChannels: 2,
		bufnum: bufnum,
		rate: BufRateScale.kr(bufnum)*rateMod,
		trigger: 1,
		startPos: 0,
		loop: 1,
		doneAction: 0,
	);



	var output = sound*ampMod;

	//var envelope2 = EnvGen.kr(Env.perc(attackTime: 2, releaseTime: 2, level: 1.0, curve: -4.0).range(1000,2500));

	output = HPF.ar(output, 1000); //LP/HP filtrering
	output = RHPF.ar(in: output, freq: 880, rq: 0.1); //LP/HP filtrering m. resonans
	output = BPF.ar(output, 880, rq: 0.1);

	//var envelope = EnvGen.kr(Env.perc(attackTime: 0.01, releaseTime: 0.01, level: 1.0, curve: -4.0));

	//output = output*envelope;

	Out.ar(0, output);
}).add;

)




// Klientside skript

(
// Kod inom parenteser körs med <cmd> och <Enter> på Mac eller <ctrl> och <Enter> i Windows

var tapping = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/cartoonTap.wav");

~strength = Synth.new(\strength, [\bufnum, tapping]);
~strength.set(\rateMod, 6); //Ändra tonhöjd
~strength.set(\ampMod, 10); //Ändra ljudvolym

)

(
// Kod inom parenteser körs med <cmd> och <Enter> på Mac eller <ctrl> och <Enter> i Windows

var sliding = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/klang.wav");

~brew = Synth.new(\brew, [\bufnum, sliding]);
~brew.set(\rateMod, 1); //Ändra tonhöjd
~brew.set(\ampMod, 10); //Ändra ljudvolym


)

(
fork({

	var sliding = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/klang.wav");
	var tapping;

	~brew = Synth.new(\brew, [\bufnum, sliding]);
	~brew.set(\rateMod, 0.3); //Ändra tonhöjd
	~brew.set(\ampMod, 5); //Ändra ljudvolym


	tapping = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/tapLight.wav");

	~brew = Synth.new(\brew, [\bufnum, tapping]);
	~brew.set(\rateMod, 3); //Ändra tonhöjd
	~brew.set(\ampMod, 5); //Ändra ljudvolym

});
)


s.record;
s.stopRecording;