library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ALU 32-bit Entity
entity alu_32bit is
    Port (
        a        : in  STD_LOGIC_VECTOR(31 downto 0);
        b        : in  STD_LOGIC_VECTOR(31 downto 0);
        op       : in  STD_LOGIC_VECTOR(3 downto 0);
        result   : out STD_LOGIC_VECTOR(31 downto 0);
        overflow : out STD_LOGIC;
        zero     : out STD_LOGIC;
        carryout : out STD_LOGIC -- เพิ่ม carryout
    );
end alu_32bit;

architecture Behavioral of alu_32bit is
    -- สัญญาณสำหรับ Carry ระหว่าง ALU1bit
    signal carry : STD_LOGIC_VECTOR(32 downto 0); -- carry(0) เป็น cin สำหรับ LSB
    -- สัญญาณสำหรับการตั้งค่า Less
    signal set   : STD_LOGIC;
    -- สัญญาณควบคุม inversion และการเลือก operation สำหรับ ALU1bit
    signal ainv, binv      : STD_LOGIC;
    signal alu_op          : STD_LOGIC_VECTOR(1 downto 0);
    -- สัญญาณสำหรับผลรวมแต่ละบิต
    signal sum             : STD_LOGIC_VECTOR(31 downto 0);
    -- สัญญาณภายในสำหรับเก็บผลลัพธ์
    signal internal_result : STD_LOGIC_VECTOR(31 downto 0);
    -- คอนสแตนต์สำหรับ Zero Comparison
    constant ZERO_VECTOR : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
begin
    -- กระบวนการถอดรหัสการทำงานตาม op
    process(op)
    begin
        case op is
            when "0000" => -- AND
                ainv <= '0';
                binv <= '0';
                alu_op <= "00";
                carry(0) <= '0';
            when "0001" => -- OR
                ainv <= '0';
                binv <= '0';
                alu_op <= "01";
                carry(0) <= '0';
            when "0010" => -- ADD
                ainv <= '0';
                binv <= '0';
                alu_op <= "10";
                carry(0) <= '0';
            when "0110" => -- SUB
                ainv <= '0';
                binv <= '1';
                alu_op <= "10";
                carry(0) <= '1';
            when "0111" => -- STL
                ainv <= '0';
                binv <= '1';
                alu_op <= "11";
                carry(0) <= '1';
            when "1100" => -- NOR
                ainv <= '1';
                binv <= '1';
                alu_op <= "00";
                carry(0) <= '0';
            when others => -- Default
                ainv <= '0';
                binv <= '0';
                alu_op <= "00";
                carry(0) <= '0';
        end case;
    end process;

    -- การสร้าง ALU1bit ตัวแรก (i = 0)
    alu0: entity work.alu_1bit
        port map (
            a       => a(0),
            b       => b(0),
            cin     => carry(0),
            ainv    => ainv,
            binv    => binv,
            op      => alu_op,
            less    => set,          -- ALU1bit ตัวแรกให้ less เชื่อมกับ set
            result  => internal_result(0),
            cout    => carry(1),
            sum     => sum(0)
        );

    -- การสร้าง ALU1bit ตัวที่ 1 ถึง 31
    gen_alu1to31: for i in 1 to 31 generate
        alu_inst: entity work.alu_1bit
            port map (
                a       => a(i),
                b       => b(i),
                cin     => carry(i),
                ainv    => ainv,
                binv    => binv,
                op      => alu_op,
                less    => '0',           -- ALU1bit ตัวอื่นๆ ให้ less เป็น 0
                result  => internal_result(i),
                cout    => carry(i+1),
                sum     => sum(i)
            );
    end generate;

    -- เชื่อมต่อ set กับ sum ของ ALU1bit ตัวสุดท้าย
    set <= sum(31);

    -- การตรวจจับ Overflow โดยใช้ Overflow_detector กับ ALU1bit ตัวสุดท้าย
    overflow_inst: entity work.overflow_detector
        port map (
            a        => a(31),
            b        => b(31),
            sum      => sum(31),
            overflow => overflow
        );

    -- การคำนวณค่า Zero โดยใช้เงื่อนไขเพื่อกำหนดค่า '1' หรือ '0'
    zero <= '1' when (internal_result = ZERO_VECTOR) else '0';

    -- กำหนดค่า output result จาก internal_result
    result <= internal_result;

    -- กำหนดค่า output carryout จาก carry ของ ALU1bit ตัวสุดท้าย
    carryout <= carry(32);
end Behavioral;
