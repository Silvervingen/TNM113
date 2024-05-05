// Starta servern
s.boot; // en rad kod körs med <Shift> och <Enter>
// Stop server
s.quit;
// Start oscilloscope
s.scope;

// leka och testa med ljudet för sensorn
(
SynthDef(\distanceSonifications, { arg freq = 500, level = 0, rate= 0;
	//var output = SinOsc.ar(350) * 1.lag(1);
	var output = LFTri.ar(500) * 1.lag(1);
	//var output = LFPar.ar(220) * 1.lag(1);
	//var output2 = LFPar.ar(400) * 1.lag(1);
	//var output3 = SinOsc.ar(200) * 1.lag(1);
	//var output2 = LFTri.ar(520) * 1.lag(1);
	var tick = LFPulse.kr(5, width:0.1).lag(0.2);

	var lfo1 = SinOsc.kr(100).range(-1,1);
	var lfo2 = SinOsc.kr(2.5).range(-1,1);
	var flow = SinOsc.ar(110);
	var noise = WhiteNoise.ar(0.25);
	noise = RLPF.ar(noise, 880)*lfo1;

	flow = noise + (flow*lfo2);



	//var env =EnvGen.kr(Env.perc(0.01,1));

	output = output*tick + flow;

	Out.ar(0, {output}!2);
}).play;

)

// När servern är igång skickar man över en eller flera synth definitioner till serven.
(
// Kod inom parenteser körs med <cmd> och <Enter> på Mac eller <ctrl> och <Enter> i Windows

SynthDef(\distanceSonification, { arg freq = 220, level = 0, rate= 0,freq2=0 ;
	var output = LFTri.ar(freq2) * level;
	var tick = LFPulse.kr(rate, width:0.1).lag(0.2);

	var lfo1 = SinOsc.kr(100).range(-1,1);
	var lfo2 = SinOsc.kr(2.5).range(-1,1);
	var flow = SinOsc.ar(110);
	var noise = PinkNoise.ar(0.25);
	noise = RLPF.ar(noise, 1000)*lfo1;
	flow = noise + (flow*lfo2);

	output = output*tick + flow*level;

	Out.ar(0, {output}!2);
}).add;



// Denna synthdefinition är en lyssnare på muspositionen på skärmen
SynthDef(\sendMouse, {
	SendReply.kr(Impulse.kr(60), '/mousePosition', [MouseX.kr(0,Window.screenBounds.right), MouseY.kr(0,Window.screenBounds.bottom), MouseButton.kr.round], 2323)
}).add;

)

(
// Följande registrerar distanceSonification synthdefinitionen på servern
~distanceSynth = Synth.new(\distanceSonification).register;

// Denna funktion är den som tar emot avståndet mellan bilen och lampan,
// och som ska användas för att mappa avståndet till olika mått och sedan
// justera synthdefinitionen (distanceSonification) på servern.
~adjustTheSonification = { arg distance; // distance är inputargumentet
	// Deklarera variabler först
	var rate =linlin(distance,0,600,7,0);
	var freq2 = linlin(rate,0,6,200,500);
	var level= linlin(distance,0,300, 1, 0.1);

	level = level * level;
	// Skriv ut avståndet i Post window
	//("The distance is:" + distance ++ "cm").postln;
	//("The rate is:" + rate ).postln;
	//("The freq is:" + freq2 ).postln;
	//("The volume is:" + level ).postln;
	// Använd case för att ändra/mappa avståndet till olika andra värden
	//case
	// För avstånd längre än 3 meter
	//{ distance > 300 } {
		//level = 0;
	//};

	if( distance > 300 ) {
		level = 0;
	};


	("The volume after case is:" + level ).postln;
	// Skicka informationen till synthdefinitionen
	~distanceSynth.set(\level, level);
	~distanceSynth.set(\rate, rate);
	~distanceSynth.set(\freq2, freq2);
};




// En del GUI-grejer
~windowWidth = Window.screenBounds.right;
~windowHeight = Window.screenBounds.bottom;
~guiPosX = ((~windowWidth/2) - (1024/2));
~guiPosY = ((~windowHeight/2) - (768/2));
w = Window.new("SID - parking assistance",
	Rect.new(
		~guiPosX,
		~guiPosY,
		1024,
		768))
.front
.background_(Color.new255(0,0,0,255));
~backgroundImage = Image.new(thisProcess.nowExecutingPath.dirname +/+ "road.png");
~viewForBackgroundImage = UserView(w, Rect(0, 0, 1024, 768));
~viewForBackgroundImage.backgroundImage = ~backgroundImage;
~carImage = Image.new(thisProcess.nowExecutingPath.dirname +/+ "car.png");
~carLayer = UserView(w, Rect(-460, 0, 1024, 768));
~carLayer.backgroundImage = ~carImage;
~carLayer.animate = true;
~lampImage = Image.new(thisProcess.nowExecutingPath.dirname +/+ "lamp.png");
~viewForBackgroundImage2 = UserView(w, Rect(0, 0, 1024, 768));
~viewForBackgroundImage2.backgroundImage = ~lampImage;
// Följande togglar en flagga true/false beroende på om musknappen är nedtryckt
// eller inte.
~mouseDownFlag = false;
~viewForBackgroundImage2.mouseDownAction = {
	~mouseDownFlag = true;
};
~viewForBackgroundImage2.mouseUpAction = {
	~mouseDownFlag = false;
};
// Följande registrerar soundMouse synthdefinitionen på servern
~mouseListener = Synth.new(\sendMouse).register;
// Följande kod är en OSC-lyssnare som tar emot information från muslyssnaren (synthdefinitionen)
// och som gör om denna info och skickar mappad information till synthdefinitionen.
o = OSCFunc({ arg msg, time, addr, recvPort;
	if (s.serverRunning) {
		var xPos = msg[3].asInteger;
		var yPos = msg[4].asInteger;
		var newX = (xPos - 740 - ~guiPosX);
		var distance;
		// Om flaggan är true är musknappen nedtryckt och bilen ska flyttas på skärmen
		if (~mouseDownFlag) {
			// Begränsa hur långt i x-led som bilen kan förflyttas
			if (newX < -460) {
				newX = -460;
			};
			if (newX > 64) {
				newX = 64;
			};
			// Flytta bilen. Använd defer för att tillåta att ett GUI-objekt manipuleras.
			{~carLayer.moveTo((newX).asInteger, 0);}.defer;
			// Denna rad gör en linjär till linjär skalning av bilens koordinater i x-led
			// till frekvens från 220 (längst till vänster) till 880 (längst till höger).
			distance = linlin(newX, -460, 64, 600, 0);
			// Denna rad ropar på funktionen adjustTheSonification och skickar med avståndet
			// till lampan som ett heltal.
			~adjustTheSonification.value(distance.asInteger);
		} {
			// Här kan kod skrivas som utförs när musknappen släpps upp.
			~distanceSynth.set(\level, 0);
		};
	};
}, '/mousePosition'); // Detta gör att OSCFunc lyssnar efter muspositionen
// Följande stänger fönstret och OSC-lyssnaren när man stänger av processen i
// SC med <ctrl> & <enter> i Windows och <cmd> & <enter> i MacOS
CmdPeriod.doOnce({
	w.free;
	w.close;
	o.free;
	o.remove;
});
)