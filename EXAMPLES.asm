// get engine base

pattern & mask:
"\x8B\x01\xF3\x0F\x10\x98\x98\x00\x00\x00", "xxxxxxxxxx"

c++ code: // captures the base address of the engine base by moving the value pointed to by ecx into the global engine_base variable then jumps to the original function
__declspec(naked) void GetEngineBaseHook() {
	__asm {
		mov eax, [ecx]
		mov engine_base, eax
		jmp GetEngineBaseOriginal
	}
}

pseudcode:
int __thiscall sub_FF5B40(float *this, int a2)

assembly:
sub_FF5B40+23D  044 8B 01                                                           mov     eax, [ecx]
sub_FF5B40+23F  044 F3 0F 10 98 98 00 00 00                                         movss   xmm3, dword ptr [eax+98h] ; Move Scalar Single-FP

// update engine

pattern & mask:
"\x81\xEC\x8C\x00\x00\x00\x53\x56\x8B\xF1\x8B\x8E\xCC\x01\x00\x00\x8B\x81\xD0\x02\x00\x00\x8B\x90\xF8\x04\x00\x00\x05\xF8\x04\x00\x00\x89\x54\x24\x08\x8B\x50\x04\x89\x54\x24\x0C\x8B\x40\x08\x89\x44\x24\x10\x8B\x81\xD0\x02\x00\x00\x8B\x88\x04\x05\x00\x00\x05\x04\x05\x00\x00\x89\x4C\x24\x6C\x8B\x50\x04\x57\x8D\x4C\x24\x64\x89\x54\x24\x74\x8B\x40\x08\x51\x8D\x4C\x24\x74\x89\x44\x24\x7C", "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

pseudocode:
int __thiscall sub_1267670(int this)

assembly:
sub_1267670      000 81 EC 8C 00 00 00                                               sub     esp, 8Ch        ; Integer Subtraction
sub_1267670+6    08C 53                                                              push    ebx
sub_1267670+7    090 56                                                              push    esi
sub_1267670+8    094 8B F1                                                           mov     esi, ecx
sub_1267670+A    094 8B 8E CC 01 00 00                                               mov     ecx, [esi+1CCh]
sub_1267670+10   094 8B 81 D0 02 00 00                                               mov     eax, [ecx+2D0h]
sub_1267670+16   094 8B 90 F8 04 00 00                                               mov     edx, [eax+4F8h]
sub_1267670+1C   094 05 F8 04 00 00                                                  add     eax, 4F8h       ; Add
sub_1267670+21   094 89 54 24 08                                                     mov     [esp+94h+var_8C], edx
sub_1267670+25   094 8B 50 04                                                        mov     edx, [eax+4]
sub_1267670+28   094 89 54 24 0C                                                     mov     [esp+94h+var_88], edx
sub_1267670+2C   094 8B 40 08                                                        mov     eax, [eax+8]
sub_1267670+2F   094 89 44 24 10                                                     mov     [esp+94h+var_84], eax
sub_1267670+33   094 8B 81 D0 02 00 00                                               mov     eax, [ecx+2D0h]
sub_1267670+39   094 8B 88 04 05 00 00                                               mov     ecx, [eax+504h]
sub_1267670+3F   094 05 04 05 00 00                                                  add     eax, 504h       ; Add
sub_1267670+44   094 89 4C 24 6C                                                     mov     [esp+94h+var_28], ecx
sub_1267670+48   094 8B 50 04                                                        mov     edx, [eax+4]
sub_1267670+4B   094 57                                                              push    edi
sub_1267670+4C   098 8D 4C 24 64                                                     lea     ecx, [esp+98h+var_34] ; Load Effective Address
sub_1267670+50   098 89 54 24 74                                                     mov     [esp+98h+var_24], edx
sub_1267670+54   098 8B 40 08                                                        mov     eax, [eax+8]
sub_1267670+57   098 51                                                              push    ecx
sub_1267670+58   09C 8D 4C 24 74

// level load

pattern & mask:
"\x6A\xFF\x68\x00\x00\x00\x00\x64\xA1\x00\x00\x00\x00\x50\x81\xEC\x00\x00\x00\x00\x53\x55\x56\x57\xA1\x00\x00\x00\x00\x33\xC4\x50\x8D\x84\x24\x00\x00\x00\x00\x64\xA3\x00\x00\x00\x00\x8B\xE9\x89\x6C\x24\x00\x00\xFF\x89", "???????xxxxxxxxx?xxxxxxxx????xxxxxx?xxxxxxxxxxxxxx??xx"

pseudocode:
int __thiscall sub_11C6A70(int *this, _DWORD *a2, int a3, int a4)

assembly:
sub_11C6A70      000 6A FF                                                           push    0FFFFFFFFh
sub_11C6A70+2    004 68 F4 52 9D 01                                                  push    offset SEH_11C6A70
sub_11C6A70+7    008 64 A1 00 00 00 00                                               mov     eax, large fs:0
sub_11C6A70+D    008 50                                                              push    eax
sub_11C6A70+E    00C 81 EC C4 00 00 00                                               sub     esp, 0C4h       ; Integer Subtraction
sub_11C6A70+14   0D0 53                                                              push    ebx
sub_11C6A70+15   0D4 55                                                              push    ebp
sub_11C6A70+16   0D8 56                                                              push    esi
sub_11C6A70+17   0DC 57                                                              push    edi
sub_11C6A70+18   0E0 A1 A0 8A F7 01                                                  mov     eax, ___security_cookie
sub_11C6A70+1D   0E0 33 C4                                                           xor     eax, esp        ; Logical Exclusive OR
sub_11C6A70+1F   0E0 50                                                              push    eax
sub_11C6A70+20   0E4 8D 84 24 D8 00 00 00                                            lea     eax, [esp+0E4h+var_C] ; Load Effective Address
sub_11C6A70+27   0E4 64 A3 00 00 00 00                                               mov     large fs:0, eax
sub_11C6A70+2D   0E4 8B E9                                                           mov     ebp, ecx
sub_11C6A70+2F   0E4 89 6C 24 30                                                     mov     [esp+0E4h+var_B4], ebp

// player ( support's Origin version )

pattern & mask:
"\x0F\xB6\x51\x68\x81", "xxxxx" - 36 // adding - 36 will move to [F3]

pseudocode:
void __thiscall sub_12B5690(int *this, int a2, _DWORD *a3)
v3 = *((unsigned __int8 *)this + 0x68); //  68 corresponds for player states such as: hanging, grounded, in-air, animation, wallrun, wallclimb, etc

assembly:
sub_12B0960      000 F3 0F 10 05 CC 49 AE 01                                         movss   xmm0, ds:dword_1AE49CC ; Move Scalar Single-FP
sub_12B0960+8    000 83 EC 0C                                                        sub     esp, 0Ch        ; Integer Subtraction
sub_12B0960+B    00C 0F 2F 44 24 10                                                  comiss  xmm0, [esp+0Ch+arg_0] ; Scalar Ordered Single-FP Compare and Set EFLAGS
sub_12B0960+10   00C 56                                                              push    esi
sub_12B0960+11   010 0F 87 5D 01 00 00                                               ja      loc_12B0AD4     ; jumptable 012B099B case 0
sub_12B0960+17   010 8B 44 24 18                                                     mov     eax, [esp+10h+arg_4]
sub_12B0960+1B   010 83 F8 07                                                        cmp     eax, 7          ; Compare Two Operands
sub_12B0960+1E   010 0F 8F 50 01 00 00                                               jg      loc_12B0AD4     ; jumptable 012B099B case 0
sub_12B0960+24   010 0F B6 51 68                                                     movzx   edx, byte ptr [ecx+68h] ; Move with Zero-Extend
sub_12B0960+28   010 81 A1 1C 04 00 00 FF FF FE FF                                   and     dword ptr [ecx+41Ch], 0FFFEFFFFh ; Logical AND
sub_12B0960+32   010 83 FA 0D                                                        cmp     edx, 0Dh        ; switch 14 cases
sub_12B0960+35   010 0F 87 F5 00 00 00                                               ja      def_12B099B     ; jumptable 012B099B default case, cases 5,6,11
sub_12B0960+3B   010 FF 24 95 DC 0A 2B 01                                            jmp     ds:jpt_12B099B[edx*4] ; switch jump

// player ( support's Steam version only )

pattern & mask:
"\x89\x0D\x00\x00\x00\x00\xB9\x00\x00\x00\x00\xFF", "xx????x????x"

c++ code:
DWORD addr;
MODULEENTRY32 mod = GetModuleInfoByName(GetCurrentProcessId(), L"mirrorsedge.exe");
addr = (DWORD)FindPattern(mod.modBaseAddr, mod.modBaseSize, "\x89\x0D\x00\x00\x00\x00\xB9\x00\x00\x00\x00\xFF", "xx????x????x") + 0x2; // adding + 0x2 will move to: [1C 3F F7 01], address part of mov dword_1F73F1C, ecx. Specifically, it targets the address 1F73F1C.
addr = 0x12B5690;
TrampolineHook(UpdatePlayerHook, (void *)addr, (void **)&PlayerHandlerOriginal);

pseudocode:
int __thiscall sub_1198580(void *this)
dword_1F73F1C = (int)this;

assembly:
sub_1198580      000 A1 20 3F F7 01                                                  mov     eax, off_1F73F20
sub_1198580+5    000 8B 10                                                           mov     edx, [eax]
sub_1198580+7    000 89 0D 1C 3F F7 01                                               mov     dword_1F73F1C, ecx
sub_1198580+D    000 B9 20 3F F7 01                                                  mov     ecx, offset off_1F73F20
sub_1198580+12   000 FF E2                                                           jmp     edx             ; Indirect Near Jump
