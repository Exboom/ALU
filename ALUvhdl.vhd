library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all; 
entity ALUvhdl is  port(  
	F: in Std_Logic_Vector(2 downto 0); -- управляющая шина        
	X: in Std_Logic_Vector(7 downto 0); -- входной сигнал x        
	Y: in Std_Logic_Vector(7 downto 0); -- входной сигнал y              
	C0: in Std_Logic; -- сигнал входного переноса         
	Z: out Std_Logic_Vector(7 downto 0) ; -- выходная шина    
	AC: out Std_uLogic; -- признаак переноса заема      
	OvF: out Std_uLogic; -- переполнение    +
	ZF: out Std_uLogic; -- признак равенства нулю     +  
	N: out Std_uLogic -- знак негативного результат  +   
	); 
	end ALUvhdl;
	
ARCHITECTURE ALU OF ALUvhdl IS   
-- процедура определения флага переполнения
procedure calc_overflow_flag (
    result          : in  std_logic_vector (15 downto 0);
    overflow_flag   : out std_logic ) is
    begin
        if( result( 15 downto 8 ) /= "00000000" ) then -- проверка старших бит
            overflow_flag := '1'; -- если не 0, то флаг 1
        else
            overflow_flag := '0'; -- если 0, то флаг 0
        end if;
    end calc_overflow_flag;
-- 
begin   
-- процесс формирования выходных сигналов в зависимости от команды на входе
	PROCESS (F,X,Y)
	variable H: Std_Logic_Vector(7 downto 0):="00000000"; 
	variable res16,X16,Y16: Std_Logic_Vector(15 downto 0); -- внутренние переменные для работы с переполнением
	variable res: Std_Logic_Vector(7 downto 0); -- внутренняя переменная результата
	variable res_ZF,res_OvF,res_CF: Std_uLogic; -- внутренняя переменная флагов
	begin
	X16:="0000000000000000";
	Y16:="0000000000000000";
	X16(7 downto 0):=X;
	Y16(7 downto 0):=Y; --обнуление переменных для работы с переносом
	CASE F is
-- X and notY
		when "000" => 
			res := X and (NOT Y);
			if (res="00000000") then -- проверка на нулевой результат
				res_ZF:='1'; -- если 0, то устанавливаем флаг нулевого результата
			else
				res_ZF:='0'; -- иначе сбрасываем
			end if;
			Z<=res;
			ZF<=res_ZF; -- присваиваем значение выходному сигналу
--notX xor Y
		when "001" => 
			res := (NOT X) xor Y;
			if (res="00000000") then -- проверка на нулевой результат
				res_ZF:='1'; -- если 0, то устанавливаем флаг нулевого результата
			else
				res_ZF:='0'; -- иначе сбрасываем
			end if;
			Z<=res;
			ZF<=res_ZF; -- присваиваем значение выходному сигналу
--Х+ циклический сдвиг Y на 5 - С0
		when "010" => 
			res16 := X16+std_logic_vector(ROTATE_LEFT(unsigned(Y16(7 downto 0)),5))-C0;
			calc_overflow_flag (res16,res_OvF);
			if (res16="0000000000000000") then -- проверка на нулевой результат
				res_ZF:='1'; -- если 0, то устанавливаем флаг нулевого результата
			else
				res_ZF:='0'; -- иначе сбрасываем
			end if;
			Z<=res16(7 downto 0);
			OvF<=res_OvF;
			ZF<=res_ZF;
--Арифметический сдвиг вправо Y-X на 2
		when "100" => 
			Z <= std_logic_vector(SHIFT_RIGHT(unsigned(Y-X),2));
		when OTHERS =>  
			Z <= H;
			report "Unknown command";
	end case;
	end process;
end ALU;