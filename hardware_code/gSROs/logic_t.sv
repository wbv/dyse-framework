//Rules for T-CELL Synchronous

module network_logic(
	input [`RULES-1:0] current_state, input clk, input reg [`LOG_RULES-1:0] rule,
	output reg [`RULES-1:0] next_state);

	/* Inputs (current state) */
	reg	TCR_curr,
		TCR_LOW_curr,
		TCR_HIGH_curr,
		CD28_curr,
		TGFBETA_curr,
		IL2_curr,
		IL2R_curr,
		AP1_curr,
		FOS_curr,
		FOS_D_curr,
		FOS_DD_curr,
		FOS_DDD_curr,
		JUN_curr,
		ERK_curr,
		MEK2_curr,
		TAK1_curr,
		MKK7_curr,
		JNK_curr,
		RAF_curr,
		RAS_curr,
		CA_curr,
		NFAT_curr,
		PKCTHETA_curr,
		NFKAPPAB_curr,
		PI3K_LOW_curr,
		PI3K_HIGH_curr,
		PI3K_curr,
		PIP3_LOW_curr,
		PIP3_HIGH_curr,
		PIP3_curr,
		PTEN_curr,
		PDK1_curr,
		AKT_curr,
		MTORC1_curr,
		MTORC2_curr,
		MTOR_curr,
		MTORC1_D_curr,
		MTORC2_D_curr,
		MTORC2_DD_curr,
		MTOR_D_curr,
		MTOR_DD_curr,
		MTOR_DDD_curr,
		MTOR_DDDD_curr,
		RHEB_curr,
		TSC_curr,
		S6K1_curr,
		PS6_curr,
		SMAD3_curr,
		JAK3_curr,
		STAT5_curr,
		STAT5_D_curr,
		STAT5_DD_curr,
		STAT5_DDD_curr,
		FOXP3_curr,
		CD25_curr,
		CD122_curr,
		CD132_curr,
		IL2_EX_curr,
		AKT_OFF_curr,
		MTORC1_OFF_curr,
		NFAT_OFF_curr;

	/* Outputs (next state) */
	reg	TCR_next,
		TCR_LOW_next,
		TCR_HIGH_next,
		CD28_next,
		TGFBETA_next,
		IL2_next,
		IL2R_next,
		AP1_next,
		FOS_next,
		FOS_D_next,
		FOS_DD_next,
		FOS_DDD_next,
		JUN_next,
		ERK_next,
		MEK2_next,
		TAK1_next,
		MKK7_next,
		JNK_next,
		RAF_next,
		RAS_next,
		CA_next,
		NFAT_next,
		PKCTHETA_next,
		NFKAPPAB_next,
		PI3K_LOW_next,
		PI3K_HIGH_next,
		PI3K_next,
		PIP3_LOW_next,
		PIP3_HIGH_next,
		PIP3_next,
		PTEN_next,
		PDK1_next,
		AKT_next,
		MTORC1_next,
		MTORC2_next,
		MTOR_next,
		MTORC1_D_next,
		MTORC2_D_next,
		MTORC2_DD_next,
		MTOR_D_next,
		MTOR_DD_next,
		MTOR_DDD_next,
		MTOR_DDDD_next,
		RHEB_next,
		TSC_next,
		S6K1_next,
		PS6_next,
		SMAD3_next,
		JAK3_next,
		STAT5_next,
		STAT5_D_next,
		STAT5_DD_next,
		STAT5_DDD_next,
		FOXP3_next,
		CD25_next,
		CD122_next,
		CD132_next,
		IL2_EX_next,
		AKT_OFF_next,
		MTORC1_OFF_next,
		NFAT_OFF_next;

	always_comb begin
		{TCR_curr,
		TCR_LOW_curr,
		TCR_HIGH_curr,
		CD28_curr,
		TGFBETA_curr,
		IL2_curr,
		IL2R_curr,
		AP1_curr,
		FOS_curr,
		FOS_D_curr,
		FOS_DD_curr,
		FOS_DDD_curr,
		JUN_curr,
		ERK_curr,
		MEK2_curr,
		TAK1_curr,
		MKK7_curr,
		JNK_curr,
		RAF_curr,
		RAS_curr,
		CA_curr,
		NFAT_curr,
		PKCTHETA_curr,
		NFKAPPAB_curr,
		PI3K_LOW_curr,
		PI3K_HIGH_curr,
		PI3K_curr,
		PIP3_LOW_curr,
		PIP3_HIGH_curr,
		PIP3_curr,
		PTEN_curr,
		PDK1_curr,
		AKT_curr,
		MTORC1_curr,
		MTORC2_curr,
		MTOR_curr,
		MTORC1_D_curr,
		MTORC2_D_curr,
		MTORC2_DD_curr,
		MTOR_D_curr,
		MTOR_DD_curr,
		MTOR_DDD_curr,
		MTOR_DDDD_curr,
		RHEB_curr,
		TSC_curr,
		S6K1_curr,
		PS6_curr,
		SMAD3_curr,
		JAK3_curr,
		STAT5_curr,
		STAT5_D_curr,
		STAT5_DD_curr,
		STAT5_DDD_curr,
		FOXP3_curr,
		CD25_curr,
		CD122_curr,
		CD132_curr,
		IL2_EX_curr,
		AKT_OFF_curr,
		MTORC1_OFF_curr,
		NFAT_OFF_curr} = current_state;
	end

	always_comb begin
			TCR_LOW_next = TCR_LOW_curr;
			TCR_HIGH_next = TCR_HIGH_curr;
			CD28_next = CD28_curr;
			TGFBETA_next = TGFBETA_curr;
			CD122_next = CD122_curr;
			CD132_next = CD132_curr;
			AKT_OFF_next = AKT_OFF_curr;
			MTORC1_OFF_next = MTORC1_OFF_curr;
			NFAT_OFF_next = NFAT_OFF_curr;
			TCR_next = TCR_curr;
			RAS_next = RAS_curr;
			RAF_next = RAF_curr;
			MEK2_next = MEK2_curr;
			ERK_next = ERK_curr;
			FOS_DDD_next = FOS_DDD_curr;
			FOS_DD_next = FOS_DD_curr;
			FOS_D_next = FOS_D_curr;
			FOS_next = FOS_curr;
			PKCTHETA_next = PKCTHETA_curr;
			TAK1_next = TAK1_curr;
			MKK7_next = MKK7_curr;
			JNK_next = JNK_curr;
			JUN_next = JUN_curr;
			AP1_next = AP1_curr;
			CA_next = CA_curr;
			NFKAPPAB_next = NFKAPPAB_curr;
			NFAT_next = NFAT_curr;
			IL2_next = IL2_curr;
			IL2R_next = IL2R_curr;
			PDK1_next = PDK1_curr;
			AKT_next = AKT_curr;
			TSC_next = TSC_curr;
			RHEB_next = RHEB_curr;
			MTORC1_D_next = MTORC1_D_curr;
			MTORC1_next = MTORC1_curr;
			MTORC2_DD_next = MTORC2_DD_curr;
			MTORC2_D_next = MTORC2_D_curr;
			MTORC2_next = MTORC2_curr;
			MTOR_DDDD_next = MTOR_DDDD_curr;
			MTOR_DDD_next = MTOR_DDD_curr;
			MTOR_DD_next = MTOR_DD_curr;
			MTOR_D_next = MTOR_D_curr;
			MTOR_next = MTOR_curr;
			S6K1_next = S6K1_curr;
			PS6_next = PS6_curr;
			SMAD3_next = SMAD3_curr;
			JAK3_next = JAK3_curr;
			STAT5_next = STAT5_curr;
			STAT5_D_next = STAT5_D_curr;
			STAT5_DD_next = STAT5_DD_curr;
			STAT5_DDD_next = STAT5_DDD_curr;
			FOXP3_next = FOXP3_curr;
			CD25_next = CD25_curr;
			PTEN_next = PTEN_curr;
			IL2_EX_next = IL2_EX_curr;
		case (rule)
			0 : TCR_next = TCR_LOW_curr | TCR_HIGH_curr;
			1 : RAS_next = (TCR_curr & CD28_curr) | (RAS_curr & IL2_EX_curr & IL2R_curr);
			2 : RAF_next = RAS_curr;
			3 : MEK2_next = RAF_curr;
			4 : ERK_next = MEK2_curr;
			5 : begin
				FOS_DDD_next = FOS_DD_curr;
				FOS_DD_next = FOS_D_curr;
				FOS_D_next = FOS_curr;
				FOS_next = ERK_curr;
			end
			6 : PKCTHETA_next = TCR_HIGH_curr | (TCR_LOW_curr & CD28_curr & MTORC2_curr);
			7 : TAK1_next = PKCTHETA_curr;
			8 : MKK7_next = TAK1_curr;
			9 : JNK_next = MKK7_curr;
			10 : JUN_next = JNK_curr;
			11 : AP1_next = FOS_DD_curr & JUN_curr;
			12 : CA_next = TCR_curr;
			13 : NFKAPPAB_next = PKCTHETA_curr | AKT_curr;
			14 : NFAT_next = CA_curr & ~NFAT_OFF_curr;
			15 : IL2_next = ((AP1_curr & NFAT_curr & NFKAPPAB_curr) | IL2_curr) & ~FOXP3_curr;
			16 : IL2R_next = CD25_curr & CD122_curr & CD132_curr;
			19 : PDK1_next = PIP3_curr;
			20 : AKT_next = PDK1_curr & MTORC2_curr & ~AKT_OFF_curr;
			21 : TSC_next = ~AKT_curr;
			22 : RHEB_next = ~TSC_curr;
			23 : begin
				MTORC1_D_next = MTORC1_curr;
				MTORC1_next = RHEB_curr & ~MTORC1_OFF_curr;
			end
			24 : begin
				MTORC2_DD_next = MTORC2_DD_curr;
				MTORC2_D_next = MTORC2_curr;
				MTORC2_next = PI3K_HIGH_curr | (PI3K_LOW_curr & ~S6K1_curr);	
			end
			25 : begin
				MTOR_DDDD_next = MTOR_DDD_curr;
				MTOR_DDD_next = MTOR_DD_curr;
				MTOR_DD_next = MTOR_D_curr;
				MTOR_D_next = MTOR_curr;
				MTOR_next = MTORC1_D_curr & MTORC2_D_curr;
			end
			26 : S6K1_next = MTORC1_curr;
			27 : PS6_next = S6K1_curr;
			28 : SMAD3_next = TGFBETA_curr;
			29 : JAK3_next = IL2R_curr & IL2_EX_curr;
			30 : STAT5_next = JAK3_curr;
			31 : STAT5_D_next = STAT5_curr;
			32 : STAT5_DD_next = STAT5_D_curr;
			33 : STAT5_DDD_next = STAT5_DD_curr;
			34 : FOXP3_next = (~MTOR_DD_curr & STAT5_curr) | (NFAT_curr & SMAD3_curr);
			35 : CD25_next = FOXP3_curr | (AP1_curr & NFAT_curr & NFKAPPAB_curr) | STAT5_curr;
			36 : PTEN_next = (~TCR_HIGH_curr & PTEN_curr) | (~TCR_HIGH_curr & FOXP3_curr);
			37 : IL2_EX_next = IL2_curr | IL2_EX_curr;
			default : ;
		endcase
	end

	always_ff @(posedge clk) begin
		case (rule)
			17 : begin
				PI3K_LOW_next <= (TCR_LOW_curr & CD28_curr) | (PI3K_LOW_curr & IL2_EX_curr & IL2R_curr);
				PI3K_HIGH_next <= (TCR_HIGH_curr & CD28_curr) | (PI3K_HIGH_curr & IL2_EX_curr & IL2R_curr);
				PI3K_next <= PI3K_LOW_curr | PI3K_HIGH_curr;
				PIP3_LOW_next <= PIP3_LOW_curr;
				PIP3_HIGH_next <= PIP3_HIGH_curr;
				PIP3_next <= PIP3_curr;
			end
			18 : begin
				PIP3_LOW_next <= PI3K_LOW_curr & ~PTEN_curr;
				PIP3_HIGH_next <= PI3K_HIGH_curr & ~PTEN_curr;
				PIP3_next <= PIP3_LOW_curr | PIP3_HIGH_curr;
				PI3K_LOW_next <= PI3K_LOW_curr;
				PI3K_HIGH_next <= PI3K_HIGH_curr;
				PI3K_next <= PI3K_curr;
			end
			default : begin
				PI3K_LOW_next <= PI3K_LOW_curr;
				PI3K_HIGH_next <= PI3K_HIGH_curr;
				PI3K_next <= PI3K_curr;
				PIP3_LOW_next <= PIP3_LOW_curr;
				PIP3_HIGH_next <= PIP3_HIGH_curr;
				PIP3_next <= PIP3_curr;
			end
		endcase
	end

	always_comb begin
		next_state =    {TCR_next,
				TCR_LOW_next,
				TCR_HIGH_next,
				CD28_next,
				TGFBETA_next,
				IL2_next,
				IL2R_next,
				AP1_next,
				FOS_next,
				FOS_D_next,
				FOS_DD_next,
				FOS_DDD_next,
				JUN_next,
				ERK_next,
				MEK2_next,
				TAK1_next,
				MKK7_next,
				JNK_next,
				RAF_next,
				RAS_next,
				CA_next,
				NFAT_next,
				PKCTHETA_next,
				NFKAPPAB_next,
				PI3K_LOW_next,
				PI3K_HIGH_next,
				PI3K_next,
				PIP3_LOW_next,
				PIP3_HIGH_next,
				PIP3_next,
				PTEN_next,
				PDK1_next,
				AKT_next,
				MTORC1_next,
				MTORC2_next,
				MTOR_next,
				MTORC1_D_next,
				MTORC2_D_next,
				MTORC2_DD_next,
				MTOR_D_next,
				MTOR_DD_next,
				MTOR_DDD_next,
				MTOR_DDDD_next,
				RHEB_next,
				TSC_next,
				S6K1_next,
				PS6_next,
				SMAD3_next,
				JAK3_next,
				STAT5_next,
				STAT5_D_next,
				STAT5_DD_next,
				STAT5_DDD_next,
				FOXP3_next,
				CD25_next,
				CD122_next,
				CD132_next,
				IL2_EX_next,
				AKT_OFF_next,
				MTORC1_OFF_next,
				NFAT_OFF_next};
	end
endmodule: network_logic
