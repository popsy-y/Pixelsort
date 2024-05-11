//  GENERAL
// ------------------
// mode
// (STL(still image), SEQ(image sequence), CAP(camera capture(experimental)), MOV(movie file))
int mode = MOV;

// canvas size
int canvSize = 1000;


//  STL / SEQ / MOV
// --------------------------
// file name
String fileName = "mov/garage.mp4";


//  SEQ / CAP / MOV
// --------------------------
// framerate cap
int targetFps = 20;

// show frametime on top left of screen
boolean showProcessTime = true;


//  SEQ
// --------------
// length of image sequence
int seqLen = 83;

// NOTE: image sequence feature currently supports only non-padded filename starts from 0.
// prefix of mage sequence
String seqPrefix = "seq/";

// suffix of image sequence
String seqSuffix = ".png";


//  SORT STACK
// ---------------------
// (or you can apply each sort manually, samples are in bottom of setup()@Pixelsort.pde)
void customSortStack(){
	doSortHush(BRI, 10, 20, VER, true, BRI);
	doSortHush(HUE, 180, 30, HOR, false, BRI);
	// showMaskHush(HUE, 180, 30);
}


// SORT FUNCTION EXPLANATION

// [ doSort / doSortHush ]
// summary: perform pixel sort. doSortHush() doesn't emit log.
// arguments:
//	 - mask mode (int, you can use: (HUE, SAT, BRI))
//	 - mask start (int)
//	 - mask range (int)
//	 - sort direction (int, you can use: (HOR, VER))
//	 - invert sort result (bool)
//	 - sort target (int, you can use: (HUE, SAT, BRI))
// example: doSort(BRI, 70, 30, VER, false, BRI);

// [ showMask / showMaskHush ]
// summary: debug function. visualise mask area. showMaskHush() doesn't emit log.
// arguments:
//	 - mask mode (int, you can use: (HUE, SAT, BRI))
//	 - mask start (int)
//	 - mask range (int)
// example: showMask(BRI, 70, 30);