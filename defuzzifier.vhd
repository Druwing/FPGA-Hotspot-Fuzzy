library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity defuzzifier is
  port (
    in_healthy_mf  : in signed(7 downto 0); -- Activation for Healthy
    in_mild_mf     : in signed(7 downto 0); -- Activation for Mild
    in_moderate_mf : in signed(7 downto 0); -- Activation for Moderate
    in_severe_mf   : in signed(7 downto 0); -- Activation for Severe
    hotspot_index  : out signed(15 downto 0) -- Crisp output: Hotspot Severity Index (e.g., Q8.8)
  );
end entity defuzzifier;

architecture behavioral of defuzzifier is
  -- Centroid values for each output fuzzy set (example values, adjust as needed)
  -- These represent the 'center' of each output linguistic term
  constant HEALTHY_CENTROID  : signed(15 downto 0) := to_signed(10 * 2**8, 16);  -- e.g., 10% severity
  constant MILD_CENTROID     : signed(15 downto 0) := to_signed(40 * 2**8, 16);  -- e.g., 40% severity
  constant MODERATE_CENTROID : signed(15 downto 0) := to_signed(70 * 2**8, 16);  -- e.g., 70% severity
  constant SEVERE_CENTROID   : signed(15 downto 0) := to_signed(95 * 2**8, 16);  -- e.g., 95% severity

  -- Function for fixed-point multiplication (assuming Q8.8 for centroids and output)
  function fixed_mult_q8_8(a, b : signed) return signed is
    variable temp_res : signed(a'length + b'length - 1 downto 0);
  begin
    temp_res := resize(a, a'length + b'length) * resize(b, a'length + b'length);
    return resize(temp_res(8 + 8 + 15 downto 8 + 8), 16); -- Result in Q8.8
  end function fixed_mult_q8_8;

begin
  process (in_healthy_mf, in_mild_mf, in_moderate_mf, in_severe_mf)
    variable numerator   : signed(31 downto 0) := (others => '0');
    variable denominator : signed(31 downto 0) := (others => '0');
    variable temp_healthy_mf  : signed(15 downto 0) := resize(in_healthy_mf, 16);
    variable temp_mild_mf     : signed(15 downto 0) := resize(in_mild_mf, 16);
    variable temp_moderate_mf : signed(15 downto 0) := resize(in_moderate_mf, 16);
    variable temp_severe_mf   : signed(15 downto 0) := resize(in_severe_mf, 16);
  begin
    -- Calculate numerator: sum(activation * centroid)
    numerator := fixed_mult_q8_8(temp_healthy_mf, HEALTHY_CENTROID) +
                 fixed_mult_q8_8(temp_mild_mf, MILD_CENTROID) +
                 fixed_mult_q8_8(temp_moderate_mf, MODERATE_CENTROID) +
                 fixed_mult_q8_8(temp_severe_mf, SEVERE_CENTROID);

    -- Calculate denominator: sum(activation)
    denominator := temp_healthy_mf + temp_mild_mf + temp_moderate_mf + temp_severe_mf;

    -- Avoid division by zero
    if denominator /= (others => '0') then
      -- Perform division (numerator / denominator) to get the crisp output
      -- This division needs to be handled carefully in fixed-point. For simplicity,
      -- we'll assume a direct division for now, but in real FPGA, this might be a divider IP or custom logic.
      hotspot_index <= resize(numerator / denominator, 16);
    else
      hotspot_index <= (others => '0'); -- No activation, no hotspot
    end if;
  end process;
end architecture behavioral;
