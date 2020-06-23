																			--Authors: Dakota Wilson, Sarah Gilliland, David Hawkins--
																								--Logic Design Project 2020--

library ieee;
use ieee.std_logic_1164.all;
																			----------REGISTER ENTITY----------
entity Reg is																
	port(
		clock	  	: in std_logic;											--Clock that is used to update the register.
		enable  	: in std_logic;											--Enable port that allows the Load entity to update register.
		inputs 		: in std_logic_vector  (7 downto 0);					--In port from the Load entity that holds the value to be loaded.
		outputs 	: out std_logic_vector (7 downto 0);					--Output port that pushes out the current value in the register. Used by other entities to update values.
		orinput 	: in std_logic_vector  (7 downto 0);					--In port from the or entity that holds the "Ored" value.
		orenable 	: in std_logic;											--Enable port that allows the Or entity to update register. 	
		andin 		: in std_logic_vector (7 downto 0);						--In port from the And entity that holds the "Anded" value to be stored.
		andenable	: in std_logic;											--Enable port that allows the And entity to update register.
		movein 		: in std_logic_vector(7 downto 0);						--In port from the Move entity that holds the value to be moved.
		moveenable 	: in std_logic;											--Enable port that allows the Move entity to update register.
		addin 		: in std_logic_vector(7 downto 0);						--In port from the Add entity that holds the added value to be stored.
		addenable 	: in std_logic;											--Enable port that allows the Add entity to update register.
		subin 		: in std_logic_vector (7 downto 0);						--In port from the Sub entity that holds the subtracted value to be stored.
		subenable 	: in std_logic;											--Enable port that allows the Sub entity to update register.
		slin 		: in std_logic_vector(7 downto 0);						--In port from the ShiftLeft entity that holds the shifted value to be stored.
		slenable 	: in std_logic;											--Enable port that allows the ShiftLeft entity to update register.
		srin		: in std_logic_vector(7 downto 0);						--In port from the ShiftRight entity that holds the shifted value to be stored.
		srenable 	: in std_logic											--Enable port that allows the ShiftRight entity to update register.
	);
end entity;

library ieee;
use ieee.std_logic_1164.all;
																			----------REGISTER ARCHITECTURE----------
architecture behavior of Reg is												
	signal value : std_logic_vector (7 downto 0);							--Signal "value" is the value that's stored in the register.
begin
	process(clock)
	begin
		if (falling_edge(clock)) then										--The if statements here test to see if any of the Enable signals from any of the other entities are equal to '1'
			if(enable = '1') then											--If an enable is found to be '1' then the register allows "value" the be changed to the input coming from that entity.
				value <= inputs;											--These if statements are also run using sequential logic, and they check each enable one at a time.
			end if;
			if(orenable = '1') then
				value <= orinput;
			end if;
			if(andenable = '1') then
				value <= andin;
			end if;
			if(moveenable = '1') then
				value <= movein;
			end if;
			if(addenable = '1') then
				value <= addin;
			end if;
			if(subenable = '1') then
				value <= subin;
			end if;
			if(slenable = '1') then
				value <= slin;
			end if;
			if(srenable = '1') then
				value <= srin;
			end if;
		end if;
	end process;
		outputs <= value;													--This gives the stored value to the outputs port, which is connected to every entity in the circuit board. This portion
end;																		--is outside of the process, and is therefore combinational logic. It is not dependent on earlier inputs.
library ieee;
use ieee.std_logic_1164.all;
																			----------OUTER ENTITY----------
entity Outer is
	port(
		mainout 		: out std_logic_vector (7 downto 0);				--Output pin that shows what's currently in the register.
		signal R1Out	: std_logic_vector (7 downto 0);					--Signal that holds the value coming directly from Register 1.
		signal R2Out	: std_logic_vector (7 downto 0);					--Signal that holds the value coming directly from Register 2.
		R1OutEn 		: std_logic;										--Enable signal that allows the outer to output what's in Register 1.
		R2OutEn 		: std_logic											--Enable signal that allows the outer to output what's in Register 2.
	);
end entity;

library ieee;
use ieee.std_logic_1164.all;
																			----------OUTER ARCHITECTURE----------
architecture behavior of Outer is
begin
	process (R1Out, R2out)															--Uses sequential logic to determine whether to output R1 or R2's value.
	begin										--The architecture uses if statements to determine whether to output R1 or R2's value.
			if(R1OutEn = '1') then
				mainout <= R1Out;
			elsif(R2OutEn = '1') then
				mainout <= R2Out;
			else
				mainout <= R1out;
			end if;
			
	end process;
	end;
	
library ieee;
use ieee.std_logic_1164.all;
																			----------LOADER ENTITY----------
entity storer is
	port(
		signal r1storeEn : std_logic;										--Signal that tells the storer entity to load the value "store" in R1.
		signal r2storeEn : std_logic;										--Signal that tells the storer entity to load the value "store" in R2.
		store 			 : out std_logic_vector(7 downto 0);				--Value that is to be loaded.
		signal command   : std_logic_vector(15 downto 0)					--Binary command passed to the microprocessor. It's passed here in order to retrieve the immediate.
	);
end entity;

library ieee;
use ieee.std_logic_1164.all;
																			----------LOADER ARCHITECTURE----------
architecture behavior of storer is
begin
	process(r2storeEn, r1storeEn, command)											--Uses sequential logic to determine whether to load or not. The sensitivity list includes the enable signals.
	begin
		if(r2storeEn = '1' or r1storeEn = '1') then							--If either one of the enable signals is one, then the value in the immediate needs to be loaded.
			Store(5) <= command(12);
			Store(4 downto 0) <= command(6 downto 2);
		end if;
	end process;
end;
	
library ieee;
use ieee.std_logic_1164.all;
																			----------OR ENTITY----------
entity orer is
	port(
		signal R1out 		: std_logic_vector (7 downto 0);				--Signal that holds the value currently stored in R1.
		signal R2out 		: std_logic_vector (7 downto 0);				--Signal that holds the value currently stored in R2.
		signal R1orR2En 	: std_logic;									--Enable that tells the entity to "or" the values in R1 and R2, and then store the result in R1.
		signal R2orR1En 	: std_logic;									--Enable that tells the entity to "or" the values in R1 and R2, and then store the result in R2.
		orstore 			: out std_logic_vector (7 downto 0)				--Output that holds the "ored" value.
	);
end entity;

library ieee;
use ieee.std_logic_1164.all;
																			----------OR ARCHITECTURE----------
architecture behavior of orer is
begin
	process(R1orR2En, R2orR1En, R1out, R2out)												--Uses sequential logic to determine whether to "or" R1 and R2's values. Sensitivity list is dependent on the enables.
	begin
		if(R1orR2En = '1' or R2orR1En = '1') then							--If either of the enables is found to be '1' then "or" the values in the registers.
			orstore <= R1out or R2out;
		end if;
	end process;
end;

library ieee;
use ieee.std_logic_1164.all;
																			----------AND ENTITY----------
entity ander is
	port(
		signal r1anden 	: std_logic;										--Enable signal that tells the entity to "and" R1's value with the immediate.
		signal r2anden	: std_logic;										--Enable signal that tells the entity to "and" R2's value with the immediate.
		andimmm			: inout std_logic_vector (7 downto 0);				--Immediate value from the command given to the microprocessor.
		signal command 	: std_logic_vector (15 downto 0);					--Command given to the microprocessor.
		signal r1out 	: std_logic_vector (7 downto 0);					--Signal that holds the value currently stored in R1.
		signal r2out 	: std_logic_vector (7 downto 0);					--Signal that holds the value currently stored in R2.
		andstore 		: out std_logic_vector (7 downto 0)					--Output that hold the "anded" value.
	);
end entity;

library ieee;
use ieee.std_logic_1164.all;
																			----------AND ARCHITECTURE----------
architecture behavior of ander is
begin
	process(r1anden, r2anden, command, andimmm, r1out, r2out)				--Uses sequential logic to determine whether to "and" R1 or R2's values with the immediate. Sensitivity list is dependent on the enables.
		begin
			if(r1anden = '1' or r2anden = '1') then							--If either of the enables is found to be '1' then retrieve the immediate from the command.
				andimmm(5) <= command(12);
				andimmm(4 downto 0) <= command(6 downto 2);
			end if;
			if(r1anden = '1') then											--If the enable signal for R1 is found to be '1' then "and" the immediate and R1's value and store the result in R1.
				andstore <= andimmm and r1out;
			elsif(r2anden = '1')then										--If the enable signal for R2 is found to be '1' then "and" the immediate and R2's value and store the result in R2.
				andstore <= andimmm and r2out;
			end if;
		end process;
end;

library ieee;
use ieee.std_logic_1164.all;
																			----------MOVE ENTITY----------
entity mover is
	port(
		signal r1movr2en	: std_logic;									--Enable signal that tells the Move entity to move the value in R2 to R1.
		signal r2movr1en	: std_logic;									--Enable signal that tells the Move entity to move the value in R2 to R1.
		movestore		  	: out std_logic_vector (7 downto 0);			--Output that stores the value to be moved.
		signal r1out 	  	: std_logic_vector (7 downto 0);				--Signal that holds the value currently stored in R1.
		signal r2out 	  	: std_logic_vector (7 downto 0)					--Signal that holds the value currently stored in R2.
	);
end entity;

library ieee;
use ieee.std_logic_1164.all;
																			----------MOVE ARCHITECTURE----------
architecture behavior of mover is
begin
	process(r1movr2en, r2movr1en, r1out, r2out)											--Uses sequential logic to determine whether to move R1 or R2's value. Sensitivity list is dependent on the enables.
	begin
		if(r1movr2en = '1') then											--If r1movr2en evaluates to '1' then the value in R2 is moved to R1.
			movestore <= r2out;
		elsif(r2movr1en = '1') then											--If r2movr1en evaluates to '1' then the value in R1 is moved to R2.
			movestore <= r1out;
		end if;
	end process;
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
																			----------ADD ENTITY----------
entity adder is
	port(										
		signal r1adden 	: std_logic;										--Enable that tells the Add entity to add the values in R1 and R2 and store the added value in R1.
		signal r2adden 	: std_logic;										--Enable that tells the Add entity to add the values in R1 and R2 and store the added value in R2.
		addstore 		: out std_logic_vector(7 downto 0);					--Output that holds the added result
		signal r1out 	: std_logic_vector(7 downto 0);						--Signal that holds the value currently stored in R1.
		signal r2out 	: std_logic_vector(7 downto 0)						--Signal that holds the value currently stored in R2.
	);
end entity;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
																			----------ADD ARCHITECTURE----------
architecture behavior of adder is
begin
	process(r1out, r2out)													--Uses sequential logic to determine whether to add R1 and R2's value.
	begin
			if(r1adden = '1') then											--The Add entity will add the values in r1out and r2out if either of the enables evaluate to '1'.
				addstore <= r1out + r2out;
			elsif(r2adden = '1') then
				addstore <= r1out + r2out;
			end if;
	end process;
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
																			----------SUBTRACT ENTITY----------
entity suber is
	port(
		signal r1suben 	: std_logic;										--Enable that tells the Subtract entity to subtract R2 from R1 and store the result in R1.
		signal r2suben 	: std_logic;										--Enable that tells the Subtract entity to subtract R1 from R2 and store the result in R2.
		substore 		: out std_logic_vector (7 downto 0);				--Stores the result of the subtraction.
		signal r1out 	: std_logic_vector (7 downto 0);					--Signal that holds the value currently stored in R1.
		signal r2out 	: std_logic_vector (7 downto 0)						--Signal that holds the value currently stored in R2.
	);
end entity;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
																			----------SUBTRACT ARCHITECTURE----------
architecture behavior of suber is
begin
	process(r1suben, r2suben, r1out, r2out)									--Uses sequential logic to determine whether to subtract R1 from R2's value or subtract R2 from R1's value.
	begin
		if(r1suben = '1') then
			substore <= r1out - r2out;
		elsif(r2suben = '1') then
			substore <= r2out - r1out;
		end if;
	end process;
end;
			
library ieee;
use ieee.std_logic_1164.all;
																			----------SHIFT LEFT ENTITY----------
entity lefter is
	port(
		slimmm 			: inout std_logic_vector (5 downto 0);				--Stores the immediate (number of bits to shift left) from the command.
		signal command 	: std_logic_vector (15 downto 0);					--Command read by the microprocessor.
		signal r1slen 	: std_logic;										--Enable that tells the entity to shift the bits in R1.
		signal r2slen 	: std_logic;										--Enable that tells the entity to shift the bits in R2.
		slstore 		: out std_logic_vector (7 downto 0);				--Stores the newly shifted value.
		signal r1out 	: std_logic_vector (7 downto 0); 					--Signal that holds the value currently stored in R1.
		signal r2out 	: std_logic_vector (7 downto 0) 					--Signal that holds the value currently stored in R2.
	);
end entity;

library ieee;
use ieee.std_logic_1164.all;
																			----------SHIFT LEFT ARCHITECTURE----------
architecture behavoir of lefter is
begin
	process(r1slen, r2slen, command, slimmm, r1out, r2out)					--Uses sequential logic to determine whether to shift the bits in R1 or R2.
	begin
		if(r1slen = '1' or r2slen = '1') then								--If either of the enables are '1' then retrieve the immediate from the command.
			slimmm(5) <= command(12);
			slimmm(4 downto 0) <= command (6 downto 2);
		end if;
		if(r1slen = '1')then
				case slimmm is												--This first case shifts the bits left.
					when "000000" =>slstore<=r1out;
					when "000001" =>slstore(7 downto 1)<=r1out(6 downto 0);
					when "000010" =>slstore(7 downto 2)<=r1out(5 downto 0);
					when "000011" =>slstore(7 downto 3)<=r1out(4 downto 0);
					when "000100" =>slstore(7 downto 4)<=r1out(3 downto 0);
					when "000101" =>slstore(7 downto 5)<=r1out(2 downto 0);
					when "000110" =>slstore(7 downto 6)<=r1out(1 downto 0);
					when "000111" =>slstore(7)<=r1out(0);
					when others =>slstore(7 downto 0)<= "00000000";
				end case;
				case slimmm is												--This second case is used to assign values to the bits that were untouched.
					when "000000" =>slstore<=r1out;							--(If this wasn't here, the bits that were left open by the shift would've diplayed as Don't Cares or X's).
					when "000001" =>slstore(0)<='0';
					when "000010" =>slstore(1 downto 0)<="00";
					when "000011" =>slstore(2 downto 0)<="000";
					when "000100" =>slstore(3 downto 0)<="0000";
					when "000101" =>slstore(4 downto 0)<="00000";
					when "000110" =>slstore(5 downto 0)<="000000";
					when "000111" =>slstore(6 downto 0)<="0000000";
					when others =>slstore(7 downto 0)<= "00000000";
				end case;
			elsif(r2slen = '1')then
				case slimmm is
					when "000000" =>slstore<=r2out;
					when "000001" =>slstore(7 downto 1)<=r2out(6 downto 0);
					when "000010" =>slstore(7 downto 2)<=r2out(5 downto 0);
					when "000011" =>slstore(7 downto 3)<=r2out(4 downto 0);
					when "000100" =>slstore(7 downto 4)<=r2out(3 downto 0);
					when "000101" =>slstore(7 downto 5)<=r2out(2 downto 0);
					when "000110" =>slstore(7 downto 6)<=r2out(1 downto 0);
					when "000111" =>slstore(7)<=r2out(0);
					when others =>slstore(7 downto 0)<= "00000000";
				end case;
				case slimmm is
					when "000000" =>slstore<=r2out;
					when "000001" =>slstore(0)<='0';
					when "000010" =>slstore(1 downto 0)<="00";
					when "000011" =>slstore(2 downto 0)<="000";
					when "000100" =>slstore(3 downto 0)<="0000";
					when "000101" =>slstore(4 downto 0)<="00000";
					when "000110" =>slstore(5 downto 0)<="000000";
					when "000111" =>slstore(6 downto 0)<="0000000";
					when others =>slstore(7 downto 0)<= "00000000";
				end case;
			end if;
	end process;
end;

library ieee;
use ieee.std_logic_1164.all;
																			----------SHIFT LEFT ENTITY----------
entity righter is
	port(
		srimmm 			: inout std_logic_vector (5 downto 0);				--Stores the immediate (number of bits to shift right) from the command.
		signal command 	: std_logic_vector (15 downto 0);					--Command read by the microprocessor.
		signal r1sren 	: std_logic;										--Enable that tells the entity to shift the bits in R1.
		signal r2sren 	: std_logic;										--Enable that tells the entity to shift the bits in R2.
		srstore 		: out std_logic_vector (7 downto 0) := "00000000";	--Stores the newly shifted value.
		signal r1out 	: std_logic_vector (7 downto 0); 					--Signal that holds the value currently stored in R1.
		signal r2out 	: std_logic_vector (7 downto 0)						--Signal that holds the value currently stored in R2.
	);
end entity;

library ieee;
use ieee.std_logic_1164.all;
																			----------SHIFT RIGHT ARCHITECTURE----------
architecture behavior of righter is
begin
	process(r1sren, r2sren, srimmm, command, r1out, r2out)					--Uses sequential logic to determine whether to shift the bits in R1 or R2.
	begin
		if(r1sren = '1' or r2sren = '1') then								--If either of the enables are '1' then retrieve the immediate from the command.
			srimmm(5) <= command(12);
			srimmm(4 downto 0) <= command (6 downto 2);
		end if;
			if(r1sren = '1')then
				case srimmm is												--This first case shifts the bits right.
					when "000000" =>srstore<=r1out;
					when "000001" =>srstore(6 downto 0)<=r1out(7 downto 1);
					when "000010" =>srstore(5 downto 0)<=r1out(7 downto 2);
					when "000011" =>srstore(4 downto 0)<=r1out(7 downto 3);
					when "000100" =>srstore(3 downto 0)<=r1out(7 downto 4);
					when "000101" =>srstore(2 downto 0)<=r1out(7 downto 5);
					when "000110" =>srstore(1 downto 0)<=r1out(7 downto 6);
					when "000111" =>srstore(0)<=r1out(7);
					when others =>srstore(7 downto 0)<= "00000000";
				end case;
				case srimmm is												--This second case is used to assign values to the bits that were untouched.
					when "000000" =>srstore<=r1out;							--(If this wasn't here, the bits that were left open by the shift would've diplayed as Don't Cares or X's).
					when "000001" =>srstore(7)<='0';
					when "000010" =>srstore(7 downto 6)<="00";
					when "000011" =>srstore(7 downto 5)<="000";
					when "000100" =>srstore(7 downto 4)<="0000";
					when "000101" =>srstore(7 downto 3)<="00000";
					when "000110" =>srstore(7 downto 2)<="000000";
					when "000111" =>srstore(7 downto 1)<="0000000";
					when others =>srstore(7 downto 0)<= "00000000"; 
				end case;
			elsif(r2sren = '1')then
				case srimmm is
					when "000000" =>srstore<=r2out;
					when "000001" =>srstore(6 downto 0)<=r2out(7 downto 1);
					when "000010" =>srstore(5 downto 0)<=r2out(7 downto 2);
					when "000011" =>srstore(4 downto 0)<=r2out(7 downto 3);
					when "000100" =>srstore(3 downto 0)<=r2out(7 downto 4);
					when "000101" =>srstore(2 downto 0)<=r2out(7 downto 5);
					when "000110" =>srstore(1 downto 0)<=r2out(7 downto 6);
					when "000111" =>srstore(0)<=r2out(7);
					when others =>srstore(7 downto 0)<= "00000000";
				end case;
				case srimmm is
					when "000000" =>srstore<=r2out;
					when "000001" =>srstore(7)<='0';
					when "000010" =>srstore(7 downto 6)<="00";
					when "000011" =>srstore(7 downto 5)<="000";
					when "000100" =>srstore(7 downto 4)<="0000";
					when "000101" =>srstore(7 downto 3)<="00000";
					when "000110" =>srstore(7 downto 2)<="000000";
					when "000111" =>srstore(7 downto 1)<="0000000";
					when others =>srstore(7 downto 0)<= "00000000"; 
				end case;
				
			end if;
	end process;
end;

library ieee;
use ieee.std_logic_1164.all;
																			----------MAIN PROJECT ENTITY----------
entity ProjectLD is 
	port(
		command : in std_logic_vector (15 downto 0);						--Command read by the microprocessor.
		exe     : in std_logic;												--Clock that is used to update the register.
		upd 	: in std_logic;												--Signal that (is supposed to) change the value of the register upon its rising edge.
		mainout : out std_logic_vector (7 downto 0)							--Output pin that shows what's currently in register R1 (and upon the Out command, what's in R2).
	);
end entity;

library ieee;
use ieee.std_logic_1164.all;
																			----------MAIN PROJECT ARCHITECTURE----------
architecture behavior of ProjectLD is
		component Reg 
		port(
			clock	  	: in std_logic;										--Clock that is used to update the register.
			enable  	: in std_logic;										--Enable passed by the Load entity used to update the register.
			inputs  	: in std_logic_vector  (7 downto 0);				--Value passed from the Load entity.
			outputs 	: out std_logic_vector (7 downto 0);				--Output port that is connected to mainout.
			orinput 	: in std_logic_vector  (7 downto 0);				--"Ored" value from the Or entity.
			orenable 	: in std_logic;										--Enable passed by the Or entity used to update the register.
			andin 		: in std_logic_vector (7 downto 0);					--Value that holds the "anded" value passed from the And entity.
			andenable	: in std_logic;										--Enable passed by the And entity used to update the register.
			movein 		: in std_logic_vector(7 downto 0);					--Value that holds the value to be moved passed from the Move entity.
			moveenable 	: in std_logic;										--Enable passed by the Move entity used to update the register.
			addin 		: in std_logic_vector(7 downto 0);					----Value that holds the added value passed from the Add entity.
			addenable 	: in std_logic;										--Enable passed by the Add entity used to update the register.
			subin 		: in std_logic_vector (7 downto 0);					--Value that holds the subtracted value passed from the Subtract entity.
			subenable 	: in std_logic;										--Enable passed by the Subtract entity used to update the register.
			slin 		: in std_logic_vector(7 downto 0);					--Value that holds the left-shifted value passed from the Shift Left entity.
			slenable 	: in std_logic;										--Enable passed by the Shift Left entity used to update the register.
			srin		: in std_logic_vector(7 downto 0);					--Value that holds the right-shifted value passed from the Shift Right entity.
			srenable 	: in std_logic										--Enable passed by the Shift Right entity used to update the register.
		);
		end component;
																			----------OUT COMPONENT----------
		component Outer				
		port(																--Ports previously defined in Entity above.
			mainout 		: out std_logic_vector (7 downto 0);
			signal R1Out   	: std_logic_vector (7 downto 0);
			signal R2Out	: std_logic_vector (7 downto 0);
			R1OutEn 		: std_logic;
			R2OutEn 		: std_logic
		);
		end component; 
																			----------LOAD COMPONENT----------
		component Storer													
		port(																--Ports previously defined in Entity above.
			signal r1storeEn : std_logic;
			signal r2storeEn : std_logic;
			store 			 : out std_logic_vector(7 downto 0);
			signal command   : std_logic_vector(15 downto 0)
		);
		end component;
																			----------OR COMPONENT----------
		component orer
		port(																--Ports previously defined in Entity above.
			signal R1out    : std_logic_vector (7 downto 0);				
			signal R2out    : std_logic_vector (7 downto 0);
			signal R1orR2En : std_logic;
			signal R2orR1En : std_logic;
			orstore 		: out std_logic_vector (7 downto 0)
		);
		end component;
																			----------AND COMPONENT----------
		component ander
		port(																--Ports previously defined in Entity above.
			signal r1anden 	: std_logic;
			signal r2anden 	: std_logic;
			andimmm 		: inout std_logic_vector (7 downto 0);
			signal command 	: std_logic_vector (15 downto 0);
			signal r1out 	: std_logic_vector (7 downto 0);
			signal r2out 	: std_logic_vector (7 downto 0);
			andstore 		: out std_logic_vector (7 downto 0)
		);
		end component;
																			----------MOVE COMPONENT----------
		component mover
		port(																--Ports previously defined in Entity above.
			signal r1movr2en 	: std_logic;
			signal r2movr1en	: std_logic;
			movestore 		  	: out std_logic_vector (7 downto 0);
			signal r1out 	  	: std_logic_vector (7 downto 0);
			signal r2out 	  	: std_logic_vector (7 downto 0)
		);
		end component;
																			----------ADD COMPONENT----------
		component adder
		port(																--Ports previously defined in Entity above.
			signal r1adden 	: std_logic;
			signal r2adden 	: std_logic;
			addstore 		: out std_logic_vector(7 downto 0);
			signal r1out 	: std_logic_vector(7 downto 0);
			signal r2out 	: std_logic_vector(7 downto 0)
		);
		end component;
																			----------SUBTRACT COMPONENT----------
		component suber
		port(																--Ports previously defined in Entity above.
			signal r1suben 	: std_logic;
			signal r2suben 	: std_logic;
			substore 		: out std_logic_vector (7 downto 0);
			signal r1out 	: std_logic_vector (7 downto 0);
			signal r2out 	: std_logic_vector (7 downto 0)
		);
		end component;
																			----------SHIFT LEFT COMPONENT----------
		component lefter
		port(																--Ports previously defined in Entity above.
			slimmm 			: inout std_logic_vector (5 downto 0);
			signal command 	: std_logic_vector (15 downto 0);
			signal r1slen	: std_logic;
			signal r2slen 	: std_logic;
			slstore 		: out std_logic_vector (7 downto 0);
			signal r1out 	: std_logic_vector (7 downto 0); 
			signal r2out   	: std_logic_vector (7 downto 0) 
		);
		end component;
																			----------SHIFT RIGHT COMPONENT----------
		component righter
		port(																--Ports previously defined in Entity above.
			srimmm 			: inout std_logic_vector (5 downto 0);
			signal command 	: std_logic_vector (15 downto 0);
			signal r1sren 	: std_logic;
			signal r2sren 	: std_logic;
			srstore 		: out std_logic_vector (7 downto 0);
			signal r1out 	: std_logic_vector (7 downto 0); 
			signal r2out 	: std_logic_vector (7 downto 0)
		);
		end component;
																			----------MULTIPLEXOR----------
								--Here, the microprocessor declares all Enable signals, and after the declarations determines their exact values from the command.
			--Once the values of each enable are determined, then the elements that make up the processor are declared, and each of the signals are directed to component they belong to.

	signal R1Out, R2Out       																																						: std_logic_vector (7 downto 0);
	signal R1StoreEn, R2StoreEn, R1OutEn, R2OutEn, R1orR2En, R2orR1En, r1anden, r2anden, r1movr2en, r2movr1en, r1adden, r2adden, r1suben, r2suben, r1slen, r2slen, r1sren, r2sren  	: std_logic;
	signal Store, orstore, andimmm, andstore, movestore, addstore, substore, slstore, srstore			  																			: std_logic_vector (7 downto 0);
	signal slimmm, srimmm 																																							: std_logic_vector (5 downto 0);
begin
	R1StoreEn 	<= not command(15) and command(14) and  not command(13) and not command(8) and command (7);
	
	R2StoreEn 	<= not command(15) and command(14) and  not command(13) and command(8) and not command (7);
	
	R1OutEn 	<= not command(12) and not command(11) and not command(10) and not command(9) and not command(8) and not command(7) and not command(3) and command(2) and command(1) and command (0);
	
	R2OutEn 	<= not command(12) and not command(11) and not command(10) and not command(9) and not command(8) and not command(7) and command(3) and not command(2) and command(1) and command (0);
	
	R1orR2En 	<= not command(12) and command(11) and command (10) and not command(8) and command(7);
	
	R2orR1En 	<= not command(12) and command(11) and command (10) and command(8) and not command(7);
	
	r1anden 	<= command(11) and not command(10) and not command(8) and command(7);
	
	r2anden 	<= command(11) and not command(10) and command(8) and not command(7);
	
	r1movr2en 	<= command(15) and not command(14) and not command(13) and command(7) and command(1) and not command(0);
	
	r2movr1en 	<= command(15) and not command(14) and not command(13) and command(8) and command(1) and not command(0);
	
	r1adden 	<= command(11) and command(10) and command(7) and not command(6) and command(5) and not command(1) and command(0);
	
	r2adden 	<= command(11) and command(10) and command(8) and not command(6) and command(5) and not command(1) and command(0);
	
	r1suben 	<= command(12) and command(11) and command(10) and command(7) and not command(6) and not command(5);
	
	r2suben 	<= command(12) and command(11) and command(10) and command(8) and not command(6) and not command(5);
	
	r1slen 		<= not command(15) and not command(14) and not command(13) and command(7);
	
	r2slen 		<= not command(15) and not command(14) and not command(13) and command(8);
	
	r1sren 		<= command(15) and not command(14) and not command(13) and not command(11) and not command(10) and command(7) and not command(1) and command(0);
	
	r2sren 		<= command(15) and not command(14) and not command(13) and not command(11) and not command(10) and command(8) and not command(1) and command(0);

	storeme 	: storer port map(r1storeEn, r2storeEn, store, command);

	orme 		: orer port map(r1out, r2out, r1orR2En, r2orR1En, orstore);

	andme 		: ander port map(r1anden, r2anden, andimmm, command, r1out, r2out, andstore);

	movme 		: mover port map(r1movr2en, r2movr1en, movestore, r1out, r2out);

	addme 		: adder port map(r1adden, r2adden, addstore, r1out, r2out);

	subme 		: suber port map(r1suben, r2suben, substore, r1out, r2out);
	
	leftme 		: lefter port map(slimmm, command, r1slen, r2slen, slstore, r1out, r2out); 
	
	rightme 	: righter port map(srimmm, command, r1sren, r2sren, srstore, r1out, r2out);
	
	R1 			: reg port map(exe, R1StoreEn, Store, R1Out, orstore, R1orR2En, andstore, r1anden, movestore, r1movr2en, addstore, r1adden, substore, r1suben, slstore, r1slen, srstore, r1sren);
	
	R2 			: reg port map(exe, R2StoreEn, Store, R2Out, orstore, R2orR1En, andstore, r2anden, movestore, r2movr1en, addstore, r2adden, substore, r2suben, slstore, r2slen, srstore, r2sren);
	
	outputer 	: outer port map(mainout, R1Out, R2Out, R1OutEn, R2OutEn);
	
end;	
