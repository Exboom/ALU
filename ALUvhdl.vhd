library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all; 
entity ALUvhdl is  port(  
	F: in Std_Logic_Vector(2 downto 0); -- ����������� ����        
	X: in Std_Logic_Vector(7 downto 0); -- ������� ������ x        
	Y: in Std_Logic_Vector(7 downto 0); -- ������� ������ y              
	C0: in Std_Logic; -- ������ �������� ��������         
	Z: out Std_Logic_Vector(7 downto 0) ; -- �������� ����    
	AC: out Std_uLogic; -- �������� �������� �����      
	OvF: out Std_uLogic; -- ������������    +
	ZF: out Std_uLogic; -- ������� ��������� ����     +  
	N: out Std_uLogic -- ���� ����������� ���������  +   
	); 
	end ALUvhdl;
	
ARCHITECTURE ALU OF ALUvhdl IS   
-- ��������� ����������� ����� ������������
procedure calc_overflow_flag (
    result          : in  std_logic_vector (15 downto 0);
    overflow_flag   : out std_logic ) is
    begin
        if( result( 15 downto 8 ) /= "00000000" ) then -- �������� ������� ���
            overflow_flag := '1'; -- ���� �� 0, �� ���� 1
        else
            overflow_flag := '0'; -- ���� 0, �� ���� 0
        end if;
    end calc_overflow_flag;
-- 
begin   
-- ������� ������������ �������� �������� � ����������� �� ������� �� �����
	PROCESS (F,X,Y)
	variable H: Std_Logic_Vector(7 downto 0):="00000000"; 
	variable res16,X16,Y16: Std_Logic_Vector(15 downto 0); -- ���������� ���������� ��� ������ � �������������
	variable res: Std_Logic_Vector(7 downto 0); -- ���������� ���������� ����������
	variable res_ZF,res_OvF,res_CF: Std_uLogic; -- ���������� ���������� ������
	begin
	X16:="0000000000000000";
	Y16:="0000000000000000";
	X16(7 downto 0):=X;
	Y16(7 downto 0):=Y; --��������� ���������� ��� ������ � ���������
	CASE F is
-- X and notY
		when "000" => 
			res := X and (NOT Y);
			if (res="00000000") then -- �������� �� ������� ���������
				res_ZF:='1'; -- ���� 0, �� ������������� ���� �������� ����������
			else
				res_ZF:='0'; -- ����� ����������
			end if;
			Z<=res;
			ZF<=res_ZF; -- ����������� �������� ��������� �������
--notX xor Y
		when "001" => 
			res := (NOT X) xor Y;
			if (res="00000000") then -- �������� �� ������� ���������
				res_ZF:='1'; -- ���� 0, �� ������������� ���� �������� ����������
			else
				res_ZF:='0'; -- ����� ����������
			end if;
			Z<=res;
			ZF<=res_ZF; -- ����������� �������� ��������� �������
--�+ ����������� ����� Y �� 5 - �0
		when "010" => 
			res16 := X16+std_logic_vector(ROTATE_LEFT(unsigned(Y16(7 downto 0)),5))-C0;
			calc_overflow_flag (res16,res_OvF);
			if (res16="0000000000000000") then -- �������� �� ������� ���������
				res_ZF:='1'; -- ���� 0, �� ������������� ���� �������� ����������
			else
				res_ZF:='0'; -- ����� ����������
			end if;
			Z<=res16(7 downto 0);
			OvF<=res_OvF;
			ZF<=res_ZF;
--�������������� ����� ������ Y-X �� 2
		when "100" => 
			Z <= std_logic_vector(SHIFT_RIGHT(unsigned(Y-X),2));
		when OTHERS =>  
			Z <= H;
			report "Unknown command";
	end case;
	end process;
end ALU;