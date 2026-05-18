library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fuzzifier_delta_isc is
  port (
    delta_isc_in : in  signed(15 downto 0); -- Delta Isc input, e.g., Q8.8 format for 0-10%
    mf_normal    : out signed(7 downto 0);  -- Membership function output for 'Normal'
    mf_small     : out signed(7 downto 0);  -- Membership function output for 'Small'
    mf_significant: out signed(7 downto 0)   -- Membership function output for 'Significant'
  );
end entity fuzzifier_delta_isc;

architecture behavioral of fuzzifier_delta_isc is
  -- Define thresholds for Delta Isc (example values, adjust as needed)
  constant DISC_NORMAL_MAX    : signed(15 downto 0) := to_signed(2 * 2**8, 16); -- 2%
  constant DISC_SMALL_MIN     : signed(15 downto 0) := to_signed(1 * 2**8, 16);  -- 1%
  constant DISC_SMALL_MAX     : signed(15 downto 0) := to_signed(5 * 2**8, 16);  -- 5%
  constant DISC_SIGNIFICANT_MIN : signed(15 downto 0) := to_signed(4 * 2**8, 16); -- 4%

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
  -- Membership function for 'Normal' (trapezoidal, e.g., 0% to 2%)
  mf_normal <= trapezoidal_mf(delta_isc_in, to_signed(0, 16), to_signed(0, 16), DISC_NORMAL_MAX, DISC_SMALL_MIN);

  -- Membership function for 'Small' (triangular, e.g., 1% to 5%)
  mf_small <= triangular_mf(delta_isc_in, DISC_SMALL_MIN, DISC_NORMAL_MAX, DISC_SMALL_MAX);

  -- Membership function for 'Significant' (trapezoidal, e.g., 4% upwards)
  mf_significant <= trapezoidal_mf(delta_isc_in, DISC_SIGNIFICANT_MIN, DISC_SMALL_MAX, to_signed(10 * 2**8, 16), to_signed(10 * 2**8, 16));

end architecture behavioral;
