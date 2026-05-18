library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fuzzifier_delta_voc is
  port (
    delta_voc_in : in  signed(15 downto 0); -- Delta Voc input, e.g., Q8.8 format for 0-5%
    mf_normal    : out signed(7 downto 0);  -- Membership function output for 'Normal'
    mf_reduced   : out signed(7 downto 0)   -- Membership function output for 'Reduced'
  );
end entity fuzzifier_delta_voc;

architecture behavioral of fuzzifier_delta_voc is
  -- Define thresholds for Delta Voc (example values, adjust as needed)
  constant DVOC_NORMAL_MAX  : signed(15 downto 0) := to_signed(1 * 2**8, 16); -- 1%
  constant DVOC_REDUCED_MIN : signed(15 downto 0) := to_signed(0 * 2**8, 16);  -- 0%
  constant DVOC_REDUCED_MAX : signed(15 downto 0) := to_signed(3 * 2**8, 16);  -- 3%

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
  -- Membership function for 'Normal' (trapezoidal, e.g., 0% to 1%)
  mf_normal <= trapezoidal_mf(delta_voc_in, to_signed(0, 16), to_signed(0, 16), DVOC_NORMAL_MAX, DVOC_REDUCED_MIN);

  -- Membership function for 'Reduced' (trapezoidal, e.g., 0% upwards)
  mf_reduced <= trapezoidal_mf(delta_voc_in, DVOC_REDUCED_MIN, DVOC_NORMAL_MAX, to_signed(5 * 2**8, 16), to_signed(5 * 2**8, 16));

end architecture behavioral;
