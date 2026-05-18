library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package fixed_point_pkg is

  -- Function to convert integer to fixed point (Q_INT.Q_FRAC)
  function to_fixed(value : integer; Q_FRAC : natural) return signed;
  -- Function to convert fixed point to integer
  function to_integer(value : signed; Q_FRAC : natural) return integer;

  -- Function to multiply two fixed point numbers
  function fixed_mult(a, b : signed; Q_FRAC_A, Q_FRAC_B : natural) return signed;
  -- Function to add two fixed point numbers
  function fixed_add(a, b : signed) return signed;
  -- Function to subtract two fixed point numbers
  function fixed_sub(a, b : signed) return signed;

end package fixed_point_pkg;

package body fixed_point_pkg is

  function to_fixed(value : integer; Q_FRAC : natural) return signed is
    variable result : signed(31 downto 0);
  begin
    result := to_signed(value * (2**Q_FRAC), 32);
    return result;
  end function to_fixed;

  function to_integer(value : signed; Q_FRAC : natural) return integer is
  begin
    return to_integer(value / (2**Q_FRAC));
  end function to_integer;

  function fixed_mult(a, b : signed; Q_FRAC_A, Q_FRAC_B : natural) return signed is
    variable temp_res : signed(a'length + b'length - 1 downto 0);
    variable result_len : natural := a'length + b'length - (Q_FRAC_A + Q_FRAC_B);
  begin
    temp_res := resize(a, a'length + b'length) * resize(b, a'length + b'length);
    -- Adjust for fractional part and resize to a reasonable length, e.g., 32 bits
    return resize(temp_res(Q_FRAC_A + Q_FRAC_B + 31 downto Q_FRAC_A + Q_FRAC_B), 32);
  end function fixed_mult;

  function fixed_add(a, b : signed) return signed is
  begin
    return resize(a + b, a'length);
  end function fixed_add;

  function fixed_sub(a, b : signed) return signed is
  begin
    return resize(a - b, a'length);
  end function fixed_sub;

end package body fixed_point_pkg;
