--! network.vhdl

--! example network: tcell network .xlsx (61 elements)

library ieee;
use ieee.std_logic_1164.all;

entity network is
	generic (
		NETWORK_SIZE: positive := 61
	);
	port (
		-- all elements have single input and output
		net:      in  std_logic_vector(NETWORK_SIZE-1 downto 0);
		net_next: out std_logic_vector(NETWORK_SIZE-1 downto 0)
	);
end entity;

architecture treg of network is
begin

	                     -- Element     = Positive                       (and not) Negative
	net_next(0)  <= (net(36) and net(30)) and not (net(1)); -- AKT         = (PDK1,MTORC2)                            AKT_OFF
	net_next(1)  <= net(1);  -- AKT_OFF     =
	net_next(2)  <= net(11) and net(19);  -- AP1         = (FOS_DD,JUN)
	net_next(3)  <= net(56);  -- CA          = TCR
	net_next(4)  <= net(4);  -- CD122       =
	net_next(5)  <= net(5);  -- CD132       =
	net_next(6)  <= net(13) or (net(2) and net(33) and net(35)) or net(51);  -- CD25        = FOXP3,(AP1,NFAT,NFKAPPAB),STAT5
	net_next(7)  <= net(7);  -- CD28        =
	net_next(8)  <= net(20);  -- ERK         = MEK2
	net_next(9)  <= net(8);  -- FOS         = ERK
	net_next(10) <= net(9); -- FOS_D       = FOS
	net_next(11) <= net(10); -- FOS_DD      = FOS_D
	net_next(12) <= net(11); -- FOS_DDD     =
	net_next(13) <= (not net(24) and net(51)) or (net(33) and net(50)); -- FOXP3       = (!MTOR_DD,STAT5),(NFAT,SMAD3)
	net_next(14) <= ((net(2) and net(33) and net(35)) or net(14)) and not (net(13)); -- IL2         = (AP1,NFAT,NFKAPPAB),IL2                  FOXP3
	net_next(15) <= net(14) or net(15); -- IL2_EX      = IL2,IL2_EX
	net_next(16) <= (net(6) and net(4) and net(5)); -- IL2R        = (CD25,CD122,CD132)
	net_next(17) <= net(16) and net(15); -- JAK3        = (IL2R,IL2_EX)
	net_next(18) <= net(21); -- JNK         = MKK7
	net_next(19) <= net(18); -- JUN         = JNK
	net_next(20) <= net(46); -- MEK2        = RAF
	net_next(21) <= net(55); -- MKK7        = TAK1
	net_next(22) <= (net(28) and net(31)); -- MTOR        = (MTORC1_D,MTORC2_D)
	net_next(23) <= net(22); -- MTOR_D      = MTOR
	net_next(24) <= net(23); -- MTOR_DD     = MTOR_D
	net_next(25) <= net(25); -- MTOR_DDD    =
	net_next(26) <= net(26); -- MTOR_DDDD   =
	net_next(27) <= (net(48)) and not net(29); -- MTORC1      = RHEB                                     MTORC1_OFF
	net_next(28) <= net(27); -- MTORC1_D    = MTORC1
	net_next(29) <= net(29); -- MTORC1_OFF  =
	net_next(30) <= net(38) or (net(39) and not net(49)); -- MTORC2      = PI3K_HIGH,(PI3K_LOW,!S6K1)
	net_next(31) <= net(30); -- MTORC2_D    = MTORC2
	net_next(32) <= net(32); -- MTORC2_DD   =
	net_next(33) <= (net(3)) and not (net(34)); -- NFAT        = CA                                       NFAT_OFF
	net_next(34) <= net(34); -- NFAT_OFF    =
	net_next(35) <= net(43) or net(0); -- NFKAPPAB    = PKCTHETA,AKT
	net_next(36) <= net(40); -- PDK1        = PIP3
	net_next(37) <= net(38) or net(39); -- PI3K        = PI3K_LOW,PI3K_HIGH
	net_next(38) <= (net(57) and net(7)) or (net(38) and net(15) and net(16)); -- PI3K_HIGH   = (TCR_HIGH,CD28),(PI3K_HIGH,IL2_EX,IL2R)
	net_next(39) <= (net(58) and net(7)) or (net(39) and net(15) and net(16)); -- PI3K_LOW    = (TCR_LOW,CD28),(PI3K_LOW,IL2_EX,IL2R)
	net_next(40) <= net(41) or net(42); -- PIP3        = PIP3_LOW,PIP3_HIGH
	net_next(41) <= net(41); -- PIP3_HIGH   = PI3K_HIGH
	net_next(42) <= net(42); -- PIP3_LOW    = PI3K_LOW
	net_next(43) <= net(57) or (net(58) and net(7) and net(30)); -- PKCTHETA    = TCR_HIGH,(TCR_LOW,CD28,MTORC2)
	net_next(44) <= net(49); -- PS6         = S6K1
	net_next(45) <= (net(45) and not net(57)) or (net(13) and not net(57)); -- PTEN        = (PTEN,!TCR_HIGH),(FOXP3,!TCR_HIGH)
	net_next(46) <= net(47); -- RAF         = RAS
	net_next(47) <= (net(56) and net(7)) or (net(47) and net(15) and net(16)); -- RAS         = (TCR,CD28),(RAS,IL2_EX,IL2R)
	net_next(48) <= net(48); -- RHEB        =                                          TSC
	net_next(49) <= net(27); -- S6K1        = MTORC1
	net_next(50) <= net(59); -- SMAD3       = TGFBETA
	net_next(51) <= net(17); -- STAT5       = JAK3
	net_next(52) <= net(51); -- STAT5_D     = STAT5
	net_next(53) <= net(53); -- STAT5_DD    =
	net_next(54) <= net(54); -- STAT5_DDD   =
	net_next(55) <= net(43); -- TAK1        = PKCTHETA
	net_next(56) <= net(57) or net(58); -- TCR         = TCR_LOW,TCR_HIGH
	net_next(57) <= net(57); -- TCR_HIGH    =
	net_next(58) <= net(58); -- TCR_LOW     =
	net_next(59) <= net(59); -- TGFBETA     =
	net_next(60) <= not net(0); -- TSC         =                                          AKT
end treg;
