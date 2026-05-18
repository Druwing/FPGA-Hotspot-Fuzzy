library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fuzzifier_ppl is
  port (
    ppl_in   : in  signed(15 downto 0); -- PPL input, e.g., Q8.8 format for 0-100%
    mf_low   : out signed(7 downto 0);  -- Membership function output for 'Low'
    mf_medium: out signed(7 downto 0);  -- Membership function output for 'Medium'
    mf_high  : out signed(7 downto 0)   -- Membership function output for 'High'
  );
end entity fuzzifier_ppl;

architecture behavioral of fuzzifier_ppl is
  -- Define thresholds for PPL (example values, adjust as needed)
  constant PPL_LOW_MAX    : signed(15 downto 0) := to_signed(10 * 2**8, 16); -- 10%
  constant PPL_MEDIUM_MIN : signed(15 downto 0) := to_signed(5 * 2**8, 16);  -- 5%
  constant PPL_MEDIUM_MAX : signed(15 downto 0) := to_signed(20 * 2**8, 16); -- 20%
  constant PPL_HIGH_MIN   : signed(15 downto 0) := to_signed(15 * 2**8, 16); -- 15%

  -- Helper function for triangular membership (0 to 255 for 0% to 100% membership)
  function triangular_mf (val, x0, x1, x2 : signed) return signed is
    variable mu : signed(7 downto 0) := (others => '0');
  begin
    if val <= x0 or val >= x2 then
      mu := (others => '0');
    elsif val >= x0 and val <= x1 then
      mu := resize((val - x0) * to_signed(255, 16) / (x1 - x0), 8);
    elsif val >= x1 and val <= x2 then
      mu := resize((x2 - val) * to_signed(255, 16) / (x2 - x1), 8);
    end if;
    return mu;
  end function triangular_mf;

  -- Helper function for trapezoidal membership (0 to 255 for 0% to 100% membership)
  function trapezoidal_mf (val, x0, x1, x2, x3 : signed) return signed is
    variable mu : signed(7 downto 0) := (others => '0');
  begin
    if val <= x0 or val >= x3 then
      mu := (others => '0');
    elsif val >= x1 and val <= x2 then
      mu := to_signed(255, 8);
    elsif val >= x0 and val <= x1 then
      mu := resize((val - x0) * to_signed(255, 16) / (x1 - x0), 8);
    elsif val >= x2 and val <= x3 then
      mu := resize((x3 - val) * to_signed(255, 16) / (x3 - x2), 8);
    end if;
    return mu;
  end function trapezoidal_mf;

begin
  -- Membership function for 'Low' (trapezoidal, e.g., 0% to 10%)
  mf_low <= trapezoidal_mf(ppl_in, to_signed(0, 16), to_signed(0, 16), PPL_LOW_MAX, PPL_MEDIUM_MIN);

  -- Membership function for 'Medium' (triangular, e.g., 5% to 20%)
  mf_medium <= triangular_mf(ppl_in, PPL_MEDIUM_MIN, PPL_LOW_MAX, PPL_MEDIUM_MAX);

  -- Membership function for 'High' (trapezoidal, e.g., 15% upwards)
  mf_high <= trapezoidal_mf(ppl_in, PPL_HIGH_MIN, PPL_MEDIUM_MAX, to_signed(100 * 2**8, 16), to_signed(100 * 2**8, 16));

end architecture behavioral;
