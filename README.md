
# Mirror's Edge

## Faith

Since Faith's body is visible and acts as its own actor with properties, Faith is controlled by two actors: her body and her camera.

### Faith's Body

The easiest way to get a valid pointer to the base address of Faith's body actor on any game version is to first search for the following assembly code in the range of `MirrorsEdge.exe`:
```asm
mov DWORD PTR 0x00000000,ecx ; 0x00000000 represents the static offset
```
Which is made up of the following bytes (in hex): `89 0D 00 00 00 00`.

However, there are multiple `mov DWORD PTR` instructions, so the next two instruction must also be searched for:
```asm
mov DWORD PTR 0x00000000,ecx ; 89 0D ?? ?? ?? ??
mov ecx, 0x00000000 ; B9 ?? ?? ?? ??
jmp r/m32 ; FF ??
```

Thus, the final byte pattern is: `89 0D ?? ?? ?? ?? B9 ?? ?? ?? ?? FF`.
Note: the final `??` byte is excluded because it is not necessary to search for.

After retrieving the static offset, the following pointer offsets are applied:
`static_offset, CC, 4A4, 214, 0`

```cpp
DWORD body_base = FindPattern(EXE.modBaseAddr, // Base
                              EXE.modBaseSize, // Search length
                              "\x89\x0D\x00\x00\x00\x00\xB9\x00\x00\x00\x00\xFF", // Bytes
                              "xx????x????x"); // Mask
							  
/* The first 2 bytes are the opcode and the r/32 byte, 
 * so the last 4 bytes of the instruction (the static offset) are needed */
body_base = *(DWORD *)(body_base + 0x2);

body_base = GetPointer(body_base, 0xCC, 0x4A4, 0x214, 0x00);
```
#### Structure

These are the currently known offsets/structure values for Faith's body actor (technically applicable to any actor):

Note: X and Y are on the horizontal axis, and Z is on the vertical axis.

| Offset (Hex) | Type         	   | Description |
|:-------------|:------------------|:------------|
| 68 		   | Byte			   | State - `0` for hanging, `1` for grounded, `2` for in-air, `3` unknown, `4` for animation, `7` unknown, `8` unknown, `9` unknown, `10`, unknown, `12` for wallrun, `13` for wallclimb|
| 78, C 	   | Float		       | Idle Animation Delay - Each time Faith moves or performs a significant action to remove her from the idle state, this idle animation delay is set to a random value between 30 and 40 (in seconds).|
| 78, 10       | Float		       | Idle Animation Timer - This is a timer that counts up every frame and, when it is greater than the idle animation delay, Faith randomly picks an idle animation to perform.|
| 7C		   | DWORD		       | Animation Object Count - The offset `78` points to an array of animation objects (including the idle animation object), so this is the number of currently active animation objects.|
| E4, 20C      | Float			   | Friction |
| E8 		   | Float			   | Position X |
| EC		   | Float			   | Position Y |
| F0 		   | Float			   | Position Z |
| F4 		   | DWORD			   | Rotation X |
| F8		   | DWORD			   | Rotation Y |
| FC 		   | DWORD			   | Rotation Z |
| 100 		   | Float			   | Velocity X |
| 104		   | Float			   | Velocity Y |
| 108 		   | Float			   | Velocity Z |
| 10C		   | Float			   | Add Velocity X |
| 110 		   | Float			   | Add Velocity Y |
| 114		   | Float			   | Add Velocity Z (Wallrun) |
| 154		   | Float			   | Proportional Scale (XYZ) |
| 158		   | Float			   | Scale X |
| 15C		   | Float			   | Scale Y |
| 160		   | Float			   | Scale Z |
| 264		   | Float			   | Max Horizontal Velocity (Ground) |
| 274		   | Float			   | Speed Gain Constant |
| 2A0		   | QWORD		       | Wallrun State |
| 2A8		   | Float	           | Wallrun |
| 2B8		   | DWORD			   | Health |
| 2BC		   | DWORD			   | Max Health |
| 2E0 		   | Float			   | Last Ground X |
| 2E4		   | Float			   | Last Ground Y |
| 2E8 		   | Float			   | Last Ground Z |
| 4CC 		   | Float			   | Prediction Vector X |
| 4D0		   | Float			   | Prediction Vector Y |
| 4D4 		   | Float			   | Prediction Vector Z |
| 4F4		   | Byte			   | Hand State - View animation state table.|
| 4FE		   | Byte			   | Movement State - View animation state table.|
| 503 		   | Byte			   | Walking State - View animation state table.|
| 505		   | Byte 			   | Action State - View animation state table.|
| 5CC 		   | Float			   | Offset X |
| 5D0		   | Float			   | Offset Y |
| 5D4 		   | Float			   | Offset Z |
| 72C		   | Float		       | Fall Z - The last Z position that Faith was grounded at, which is used for determining what kind of fall she will have when she hits the ground (death, roll, etc).|

#### Animation State

These are the currently known combinations for the Hand, Movement, Walking, and Action State animation bytes.

| Hand | Movement | Walking | Action | Animation |
|:-----|:---------|:--------|:-------|:----------|
| 0    | 1        | 0       |        | Standing  |
| 0    | 1        | 1       |        | Standing  |
| > 0  | 1        | 0       |        | Hands Against Wall |
| > 0  | 1        | 1       |        | Hands Against Wall |
|      | 1		  | 2       |        | Walking   |
|      | 1        | 3       |        | Walking   |
|      | 1		  | 4       |        | Running   |
|      | 1        | 5       |        | Running   |
|      | 2        |         |        | Uncontrollable Faith |
|      | 3        |         |        | Hanging |
|      | 4        |         |        | Wallrun |
|      | 5        |         |        | Wallrun |
|      | 6        |         |        | Wallclimb |
|      | 7        |         |        | Springboard |
|      | 10       |         |        | Pull Up |
|      | 11       | 0       |        | Vertical Jump |
|      | 11       | 1       |        | Vertical Jump |
|      | 11       | 2       |        | Forward Jump |
|      | 11       | 3       |        | Forward Jump |
|      | 11       | 4       |        | Forward Jump |
|      | 11       | 5       |        | Forward Jump |
|      | 15       | 0       |        | Crouch |
|      | 15       | 1       | 1      | Crouch Walking Forward 1|
|      | 15       | 2       | 1      | Crouch Walking Forward 1|
|      | 15       | 1       | 2      | Crouch Walking Forward 2|
|      | 15       | 2       | 2      | Crouch Walking Forward 2|
|      | 15       | 1       | 3      | Crouch Walking Forward 3|
|      | 15       | 2       | 3      | Crouch Walking Forward 3|
|      | 15       | 1       | 4      | Crouch Walking Forward 4|
|      | 15       | 2       | 4      | Crouch Walking Forward 4|
|      | 16       |         |        | Slide |
|      | 19       |         |        | Melee |
|      | 19       |         |        | Barge |
|      | 21       |         | 0      | Pipe Idle |
|      | 21       |         | 3      | Pipe Climb Up |
|      | 21       |         | 4      | Pipe Climb Down |
|      | 22       |         |        | Into Pipe Climb |
|      | 24       |         |        | Quick Turn |
|      | 25       |         |        | Quick Turn In-Air |
|      | 26       |         |        | Laying on Back |
|      | 27       |         |        | Into Zipline |
|      | 28       |         |        | Zipline |
|      | 30       | 0       |        | Ledge Stand |
|      | 30       | 2       |        | Ledge Move |
|      | 31       |         |        | Transfer Pipe Climb |
|      | 32       | 0       |        | Drop Kick |
|      | 32       | 1       |        | Drop Kick |
|      | 32       | 2       |        | Forward Drop Kick |
|      | 32       | 3       |        | Jump Kick |
|      | 32       | 4       |        | Jump Kick |
|      | 32       | 5       |        | Jump Kick |
|      | 33       |         | 1      | Sidestep Left |
|      | 33       |         | 2      | Sidestep Right |
|      | 34       |         |        | Wallrun Sidestep |
|      | 38       |         |        | Ramp Slide |
|      | 39       |         |        | Interact |
|      | 48       |         |        | Melee Slide |
|      | 49       |         |        | Wallclimb Sidestep |
|      | 61       |         |        | Coiling |
|      | 62       |         |        | Wallrun Kick |
|      | 63       |         |        | Melee Crouch |
|      | 72       |         |        | Death Fall |
|      | 91       |         |        | Rolling |

### Faith's Camera

## Engine

Mirror's Edge uses Unreal Engine 3, so resources can be created and edited using the UE3 Editor.

### Level Streaming

Mirror's Edge dynamically loads sublevels while the user is playing to create a non-stop user experience. The Level Stream function's prototype is as follows:
```cpp
int __thiscall LevelStream (LEVEL_INFO *level_info);
```
The full layout of the `LEVEL_INFO` structure is not known, but the only variables needed to manually level stream are:

| Offset (Hex) | Type  | Description |
|:-------------|:------|:------------|
| 2C           | Byte  | Unload Boolean (0 for load, 1 for unload) |
| 88           | DWORD | Pointer to array of sublevels
| F0           | DWORD | Pointer to array of sublevels |
| F4		   | DWORD | Number of sublevels in array |

Sublevel structure:

| Offset (Hex) | Type  | Description |
|:-------------|:------|:------------|
| 4            | DWORD | Sublevel ID |
| C            | Byte  | Load Boolean (0 for unload, 1 for load) - Keep consistent with `LEVEL_INFO` unload boolean. |

Given these structures and some dummy `LEVEL_INFO` data taken from an actual `LevelStream` call, a manual level streaming function can easily be created:

```cpp
void LevelStream(DWORD id, char load) {
	static char data[] = { 0, 0, 0, 0, 76, -112, 0, 0, 0, 0, 0, 0, 1, 78, 113, 81, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 1, 127, 0, 0, -28, 0, 7, 0, -62, 1, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, 9, 0, 1, 0, -62, 2, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, -27, 0, 1, 0, 4, 66, -128, 1, 0, 0, -128, 3, 0, 0, 0, 0, -26, 0, 1, 0, 2, 0, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, -28, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, -96, 78, 113, 81, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1, -80, 74, 113, 81, -80, 67, 113, 81, -1, -1, -1, -1, -96, 78, 113, 81, 1, 0, 0, 0, -107, -89, -33, 34, 0, 77, 1, -128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -96, 79, 113, 81, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 127, 0, 0, -28, 0, 7, 0, -126, 1, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, 7, 0, 0, 0, -126, 2, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, -30, 0, 1, 0, -60, 64, -128, 1, 0, 0, -128, 3, 0, 0, 0, 0, -28, 0, 1, 0, 2, 0, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, -28, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1, -80, 95, 113, 81, -80, 73, 113, 81, -1, -1, -1, -1, -1, -1, -1, 127, 0, 0, 0, 0, 117, -92, -65, 34, 0, 78, 1, -128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -96, 80, 113, 81, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 29, 0, 0, 0, 1, 127, 0, 0, -28, 0, 7, 0, 66, 2, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, 2, 0, 1, 0, -62, 1, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, 85, 0, 1, 2, 2, 0, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, -28, 0, 1, 0, 2, 0, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, -28, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1, -80, 81, 113, 81, -80, 88, 113, 81, -1, -1, -1, -1, -1, -1, -1, 127, 0, 0, 0, 0, 85, -92, -97, 34, 0, 79, 1, -128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -96, 81, 113, 81, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 29, 0, 0, 0, 1, 127, 0, 0, -28, 0, 7, 0, 66, 2, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, 4, 0, 1, 0, -62, 1, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, -86, 0, 1, 2, 2, 0, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, -28, 0, 1, 0, 2, 0, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, -28, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1, -80, 91, 113, 81, -80, 80, 113, 81, -1, -1, -1, -1, -1, -1, -1, 127, 0, 0, 0, 0, 53, -92, 127, 33, 0, 80, 1, -128, 92, 0, 63, 0, 63, 0, 92, 0, 67, 0, 58, 0, 92, 0, 85, 0, 115, 0, 101, 0, 114, 0, 115, 0, 92, 0, 66, 0, 114, 0, 105, 0, 97, 0, 110, 0, 92, 0, 68, 0, 111, 0, 99, 0, 117, 0, 109, 0, 101, 0, 110, 0, 116, 0, 115, 0, 92, 0, 69, 0, 65, 0, 32, 0, 71, 0, 97, 0, 109, 0, 101, 0, 115, 0, 92, 0, 77, 0, 105, 0, 114, 0, 114, 0, 111, 0, 114, 0, 39, 0, 115, 0, 32, 0, 69, 0, 100, 0, 103, 0, 101, 0, 92, 0, 84, 0, 100, 0, 71, 0, 97, 0, 109, 0, 101, 0, 92, 0, 80, 0, 117, 0, 98, 0, 108, 0, 105, 0, 115, 0, 104, 0, 101, 0, 100, 0, 92, 0, 67, 0, 111, 0, 111, 0, 107, 0, 101, 0, 100, 0, 80, 0, 67, 0, 92, 0, 77, 0, 97, 0, 112, 0, 115, 0, 92, 0, 83, 0, 80, 0, 48, 0, 49, 0, 92, 0, 69, 0, 100, 0, 103, 0, 101, 0, 95, 0, 80, 0, 116, 0, 50, 0, 95, 0, 65, 0, 117, 0, 100, 0, 46, 0, 109, 0, 101, 0, 49, 0, 46, 0, 117, 0, 110, 0, 99, 0, 111, 0, 109, 0, 112, 0, 114, 0, 101, 0, 115, 0, 115, 0, 101, 0, 100, 0, 95, 0, 115, 0, 105, 0, 122, 0, 101, 0, 0, 0, 0, 0, 21, -92, 95, 33, 0, 81, 1, -128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -96, 83, 113, 81, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 1, 127, 0, 0, -28, 0, 7, 0, -62, 2, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, 12, 0, 1, 0, 66, 2, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, 85, 0, 1, 0, -126, 2, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, 68, 0, 1, 0, 2, 0, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, -28, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1, -80, 68, 113, 81, -80, 82, 113, 81, -1, -1, -1, -1, -1, -1, -1, 127, 0, 0, 0, 0, -11, -92, 63, 33, 0, 82, 1, -128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -96, 84, 113, 81, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 1, 127, 0, 0, -28, 0, 7, 0, -126, 1, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, 7, 0, 1, 0, 2, 2, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, -86, 0, 1, 0, -126, 1, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, -28, 0, 1, 0, -62, 1, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, -7, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1, -80, 76, 113, 81, -80, 91, 113, 81, -1, -1, -1, -1, -1, -1, -1, 127, 0, 0, 0, 0, -43, -92, 31, 33, 0, 83, 1, -128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -96, 85, 113, 81, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 127, 0, 0, -28, 0, 7, 0, -126, 1, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, 7, 0, 0, 0, 66, 1, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, -28, 0, 1, 0, 2, 2, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, 85, 0, 1, 0, 2, 0, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, -28, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1, -80, 73, 113, 81, -80, 90, 113, 81, -1, -1, -1, -1, -1, -1, -1, 127, 0, 0, 0, 0, -75, -92, -1, 33, 0, 84, 1, -128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -96, 86, 113, 81, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 1, 127, 0, 0, -28, 0, 7, 0, 2, 2, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, 10, 0, 1, 0, 64, 0, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, 96, 0, 1, 0, 4, 66, -128, 1, 0, 0, -128, 3, 0, 0, 0, 0, 96, 0, 1, 0, 66, 1, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, -1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1, -80, 95, 113, 81, -80, 92, 113, 81, -1, -1, -1, -1, -1, -1, -1, 127, 0, 0, 0, 0, -107, -92, -33, 33, 0, 85, 1, -128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -96, 87, 113, 81, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 1, 127, 0, 0, -28, 0, 7, 0, 66, 2, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, 2, 0, 33, 0, -62, 1, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, -28, 0, 1, 0, -123, 67, -128, 1, 0, 0, -128, 3, 0, 0, 0, 0, -28, 0, 1, 0, 2, 0, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, -28, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, -13, 4, 53, -65, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, -20, 5, -47, -66, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 58, -51, 19, 63, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, -13, 4, 53, 63, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1, -80, 97, 113, 81, -80, 69, 113, 81, -1, -1, -1, -1, -1, -1, -1, 127, 0, 0, 0, 0, 117, -91, -65, 33, 0, 86, 1, -128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -96, 88, 113, 81, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 29, 0, 0, 0, 1, 127, 0, 0, -28, 0, 7, 0, 66, 2, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, 1, 0, 1, 0, -62, 1, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, 0, 0, 1, 2, 2, 0, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, -28, 0, 1, 0, 2, 0, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, -28, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1, -80, 80, 113, 81, -80, 79, 113, 81, -1, -1, -1, -1, -1, -1, -1, 127, 0, 0, 0, 0, 85, -91, -97, 33, 0, 87, 1, -128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -96, 89, 113, 81, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 1, 127, 0, 0, -28, 0, 7, 0, -126, 1, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, 7, 0, 1, 0, -126, 1, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, -28, 0, 1, 0, -126, 1, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, -28, 0, 1, 0, 2, 0, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, -28, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1, -80, 90, 113, 81, -80, 72, 113, 81, -1, -1, -1, -1, -1, -1, -1, 127, 0, 0, 0, 0, 53, -91, 127, 32, 0, 88, 1, -128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -96, 90, 113, 81, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 127, 0, 0, -28, 0, 7, 0, 2, 0, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, 8, 0, 1, 0, -128, 0, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, -1, 0, 1, 0, 2, 0, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, -28, 0, 1, 0, 2, 0, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, -28, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1, -80, 96, 113, 81, -80, 69, 113, 81, -1, -1, -1, -1, -1, -1, -1, 127, 0, 0, 0, 0, 21, -91, 95, 32, 0, 89, 1, -128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -96, 91, 113, 81, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 1, 127, 0, 0, -28, 0, 7, 0, -126, 1, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, 7, 0, 1, 0, -126, 1, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, -86, 0, 1, 0, 66, 2, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, -28, 0, 1, 0, -126, 1, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, -12, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1, -80, 84, 113, 81, -80, 60, 113, 81, -1, -1, -1, -1, -1, -1, -1, 127, 0, 0, 0, 0, -11, -91, 63, 32, 0, 90, 1, -128, 67, 0, 58, 0, 92, 0, 87, 0, 73, 0, 78, 0, 68, 0, 79, 0, 87, 0, 83, 0, 92, 0, 87, 0, 105, 0, 110, 0, 83, 0, 120, 0, 83, 0, 92, 0, 120, 0, 56, 0, 54, 0, 95, 0, 109, 0, 105, 0, 99, 0, 114, 0, 111, 0, 115, 0, 111, 0, 102, 0, 116, 0, 46, 0, 119, 0, 105, 0, 110, 0, 100, 0, 111, 0, 119, 0, 115, 0, 46, 0, 99, 0, 111, 0, 109, 0, 109, 0, 111, 0, 110, 0, 45, 0, 99, 0, 111, 0, 110, 0, 116, 0, 114, 0, 111, 0, 108, 0, 115, 0, 95, 0, 54, 0, 53, 0, 57, 0, 53, 0, 98, 0, 54, 0, 52, 0, 49, 0, 52, 0, 52, 0, 99, 0, 99, 0, 102, 0, 49, 0, 100, 0, 102, 0, 95, 0, 54, 0, 46, 0, 48, 0, 46, 0, 49, 0, 52, 0, 51, 0, 57, 0, 51, 0, 46, 0, 52, 0, 52, 0, 55, 0, 95, 0, 110, 0, 111, 0, 110, 0, 101, 0, 95, 0, 56, 0, 57, 0, 99, 0, 54, 0, 52, 0, 100, 0, 50, 0, 56, 0, 100, 0, 97, 0, 102, 0, 101, 0, 97, 0, 52, 0, 98, 0, 57, 0, 92, 0, 99, 0, 111, 0, 109, 0, 99, 0, 116, 0, 108, 0, 51, 0, 50, 0, 46, 0, 100, 0, 108, 0, 108, 0, 0, 0, 0, 0, 0, 0, -43, -91, 31, 32, 0, 91, 1, -128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -96, 93, 113, 81, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 127, 0, 0, -28, 0, 7, 0, -62, 1, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, 10, 0, 0, 0, -62, 2, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, -96, 0, 1, 0, -126, 1, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, -96, 0, 1, 0, 2, 0, 0, 0, 0, 0, -128, 3, 0, 0, 0, 0, -28, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1, -80, 92, 113, 81, -80, 67, 113, 81, -1, -1, -1, -1, -1, -1, -1, 127, 0, 0, 0, 0, -75, -91, -1, 32, 0, 92, 1 };

	char *buffer = (char *)malloc(sizeof(data));
	memcpy(buffer, data, sizeof(data));

	*(DWORD **)(buffer + 0xF0) = (DWORD *)buffer;
	*(DWORD *)(buffer + 0x4) = id;
	*(DWORD *)(buffer + 0xF4) = 1;

	*(char **)(buffer + 0x88) = (char *)buffer;
	*(char *)(buffer + 0xC) = load;
	*(char *)(buffer + 0x2C) = 1 - load;

	LevelStreamOriginal((DWORD)buffer);

	free(buffer);
}
```

### Sublevels

At any point in the process (including main menu), there is a list of the sublevels for the current level. To get this list, the following pointers are used:

Sublevel Count: `static_offset, 50, 3C, 0, BF0`

Sublevel Array Base: `static_offset, 50, 3C, 0, BEC`

Where the `static_offset` is found by this byte pattern plus `E`: `8B 41 04 56 33 F6 39 71 08 89 71 10 8B 15`

#### Traversing through the Sublevel Array

Traversing through the sublevel array is quite simple after retrieving the count and base:

```cpp
DWORD sublevel_list = FindPattern(EXE.modBaseAddr,
                                  EXE.modBaseSize,
                                  "\x8B\x41\x04\x56\x33\xF6\x39\x71\x08\x89\x71\x10\x8B\x15",
                                  "xxxxxxxxxxxxxx");
sublevel_list = *(DWORD *)(sublevel_list + 0xE);

sublevel_list = GetPointer(sublevel_list, 0x50, 0x3C, 0x00, 0x00);

DWORD sublevel_count = *(DWORD *)(sublevel_list + 0xBF0);
sublevel_list = *(DWORD *)(sublevel_list + 0xBEC);

for (int i = 0; i < sublevel_count; i++) {
	DWORD sublevel = *(DWORD *)(sublevel_list + (i * 4));
	if (!sublevel) {
		continue;
	}
	
	DWORD sublevel_id = *(DWORD *)(sublevel + 0x3C);
}
```

#### Sublevel Strings

In addition, each sublevel has a `wchar` string that corresponds with it. Getting the string for a sublevel by its id can be done through the following code:

```cpp
void GetSublevelStringById(DWORD id, char *out) {
	DWORD string_table = FindPattern(EXE.modBaseAddr,
                                     EXE.modBaseSize,
                                     "\x33\xC4\x50\x8D\x44\x24\x18\x64\xA3\x00\x00\x00\x00\x8B\xD9\x33\xED\x89\x6C\x24\x14\x8B\x03\x8B\x0D",
                                     "xxxxxxxxxxxxxxxxxxxxxxxxx");
									 
	string_table = *(DWORD *)(string_table + 0x19);
	
	wchar_t *str = *(wchar_t **)string_table;
	str = *(wchar_t **)((DWORD)str + (id * 4));
	str = (wchar_t *)((DWORD)ptr + 0x10);
	
	sprintf(out, "%ws", str);
}
```


# Strangs

All offsets below are for the Steam version.

## Handler Skips and Strangs

A handler skip is a single frame where the difference in frame time was too small, so the game skips the handler function for Faith's current state.

The game calculates the difference in frame time as described by the pseudo-code below:

```cpp
double seconds_per_tick = 1.0 / QueryPerformanceFrequency; // 0x2020738

double current, // 0x2027FA8
       last,    // 0x1F98618
       delta;   // 0x1F723E0
		   
for (;;) {
	/*** 0x404140 ***/
	current = (double)QueryPerformanceCounterQuadPart * seconds_per_tick + 16777216.0;
	delta = current - last;
	Tick(delta);
	last = current;
}
```

However, this difference in frame time (delta) is manipulated as the game passes it down to the current state handler.

At `0xB5BA00`, the game multiplies delta by the current time dialation (between `0` and `1`) and caps it at `0.4`.

Then for when Faith is landing, the game will calcluate the difference in current position to predicted position, and determine how to scale delta such that Faith doesn't fall below the floor (`0xDBB07D` for prediction -> `0x12C177D` for adjusting delta) because her velocities are scaled by delta.

Then delta is passed to this function, and the skip in calling the handler caused by a too small delta can be seen in the pseudo-code below:

```cpp
/*** 0x12B0960 ***/
void __thiscall CallStateHandler(byte *this, float diff, int a3) {
	if (diff >= 0.0003) { // A handler skip will occur because diff is smaller than 0.0003
		... // Call corresponding handler
	}
}
```

For a strang, a handler skip occurs on the frame Faith is walking between two jumps:

- ```(jump) -> (falling) -> (walking, but handler is skipped) -> (jump)```

Once Faith lands, this function in `TdGame.u->TdMove_Landing` is called:
```js
simulated function SubtractLandingSpeed() {
    local TdMove_Jump JumpMove;
    local TdMove_Falling FallMove;
    local Vector NewVelocity;
    local bool bShouldSubtract;

    FallMove = TdMove_Falling(PawnOwner.Moves[2]);
    bShouldSubtract = (PawnOwner.OldMovementState == 2 && (FallMove.PreviousMove == 11 || FallMove.PreviousMove == 32)) || PawnOwner.OldMovementState == 61 || PawnOwner.OldMovementState == 32;
    if (bShouldSubtract && PawnOwner.GetWeaponType() != 1) {
        JumpMove = TdMove_Jump(PawnOwner.Moves[11]);
        // LandingSpeedReduction is 65u/s
        if ((JumpMove.PreJumpMomentum - LandingSpeedReduction) < VSize2D(PawnOwner.Velocity)) {
            NewVelocity = PawnOwner.Velocity;
            NewVelocity.Z = 0.0;
            NewVelocity = Normal(NewVelocity) * (JumpMove.PreJumpMomentum - LandingSpeedReduction);
            NewVelocity.Z = PawnOwner.Velocity.Z;
            PawnOwner.Velocity = NewVelocity;
        }
    } 
}
```

Essentially, the game will subtract speed upon landing if:
- Faith's last movement state was free fall (2), which will be triggered if her vertical velocity is less than `-400u/s`, AND her previous move before the free fall was a standard jump or a kick.
- OR if Faith's previous movement state was a jumping coil.
- OR if Faith's previous movement state was a kick.
- AND if Faith's `PreJumpSpeed - 65.0u/s < CurrentSpeed`

Then the walking handler (`0x12BEF70`) is supposed to be called, but is skipped. Simply put, the walking handler would have adjusted Faith's speed.

### Walking Handler

If Faith's X, Y, and Z acceleration are less than `0.0001u/s^2`, which signifies a smooth continuous jump, the game will adjust Faith's velocity by the following:
```c
/*** 0x12B31AA ***/
float accel_const = *(float *)(faith_actor_base + 0x274); // 6144 by default
float mag = vx * vx + vy * vy + vz * vz;
float speed = sqrt(mag);
float gain = (3.0 - (((1.0 / speed) * mag) * (1.0 / speed))) * ((1.0 / speed) * 0.5);
float jerk = velocity * gain;
acceleration += (jerk * accel_const);

velocity += (acceleration * delta);
```

This change in acceleration causes a speed gain. However, if Faith does a non-smooth continuous jump, then she will not gain enough speed to cancel the landing speed reduction. 

The walking handler will finally cap Faith's speed at `720u/s`.

## Conclusion

A frame where the walking handler is skipped would cause:
- Strang after a wallboost
	- Faith's last movement state was free fall but her previous move before the free fall was a wallrun jump.
	- No landing speed subtracted.
- Strang by jumping on a ledge/platform higher than Faith's initial position
	- Faith's vertical velocity does not go below `-400u/s`, so her last movement state is not free fall.
	- No landing speed subtracted.
- Strang falling from zipline
	- Faith's last movement state was free fall but her previous move before the free fall was a zipline hang.
	- No landing speed subtracted.
- Loss in speed while bunny hopping in a straight line
	- Since the walking handler was skipped, there is no speed gain for the continuous jump.
	- Landing speed still subtracted.
	
Note: Faith's main state, which determines what actions are available (i.e. jumping) and Faith's physics, is still changed even when the movement state is not.
