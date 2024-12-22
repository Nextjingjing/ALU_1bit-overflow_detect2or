library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity overflow_detector is
    Port (
        a       : in  STD_LOGIC;
        b       : in  STD_LOGIC;
        sum     : in  STD_LOGIC;
        overflow : out STD_LOGIC
    );
end Overflow_detector;

architecture Behavioral of Overflow_detector is
begin
    process(a, b, sum)
    begin
        -- Logic of Overflow
        overflow <= ((a xor b) and not sum) or (a and b);
    end process;

end Behavioral;