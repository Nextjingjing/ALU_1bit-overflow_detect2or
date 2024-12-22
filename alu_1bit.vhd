library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu_1bit is
    Port (
        a       : in  STD_LOGIC;
        b       : in  STD_LOGIC;
        cin     : in  STD_LOGIC;
        ainv    : in  STD_LOGIC;
        binv    : in  STD_LOGIC;
        op      : in  STD_LOGIC_VECTOR(1 downto 0);
        less    : in  STD_LOGIC;
        result  : out STD_LOGIC;
        cout    : out STD_LOGIC;
        sum     : out STD_LOGIC
    );
end alu_1bit;

architecture Behavioral of alu_1bit is
    signal a_val    : STD_LOGIC;
    signal b_val    : STD_LOGIC;
    signal sum_val  : STD_LOGIC;
    signal carry_val: STD_LOGIC;
    signal and_res  : STD_LOGIC;
    signal or_res   : STD_LOGIC;
begin

    process(a, b, cin, ainv, binv, op, less)
    begin
        -- Invert inputs if needed
        if ainv = '1' then
            a_val <= not a;
        else
            a_val <= a;
        end if;

        if binv = '1' then
            b_val <= not b;
        else
            b_val <= b;
        end if;

        -- Compute intermediate results
        sum_val <= a_val xor b_val xor cin;
        carry_val <= (a_val and b_val) or (b_val and cin) or (a_val and cin);
        and_res <= a_val and b_val;
        or_res <= a_val or b_val;

        -- Select operation based on 'op'
        case op is
            when "00" =>  -- AND
                result <= and_res;
            when "01" =>  -- OR
                result <= or_res;
            when "10" =>  -- ADD
                result <= sum_val;
            when "11" =>  -- SLT
                result <= less;
            when others =>
                result <= '0';
        end case;

        -- Set carry out
        cout <= carry_val;

        -- Output sum value
        sum <= sum_val;
    end process;

end Behavioral;
