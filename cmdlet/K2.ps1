Function Ddump-K2 {
    param([String]$Tag)

    Ainit

	if ($Tag -ne '') {
		$Tag = $Tag + "-K2"
	}

    Ddump -Device1 1-0040 -Device2 1-0042 -SoundCard lahaina-mtp-snd-card -Prefix $Tag
}

Function Ddump-regs-K2 {
    Ainit
    Ddump-regs -Device1 1-0040 -Device2 1-0042
}
