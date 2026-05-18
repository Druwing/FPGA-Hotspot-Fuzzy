library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fuzzy_rule_base is
  port (
    -- Fuzzified inputs from PPL
    ppl_low_mf   : in signed(7 downto 0);
    ppl_medium_mf: in signed(7 downto 0);
    ppl_high_mf  : in signed(7 downto 0);

    -- Fuzzified inputs from Delta Isc
    disc_normal_mf    : in signed(7 downto 0);
    disc_small_mf     : in signed(7 downto 0);
    disc_significant_mf: in signed(7 downto 0);

    -- Fuzzified inputs from Delta Voc
    dvoc_normal_mf : in signed(7 downto 0);
    dvoc_reduced_mf: in signed(7 downto 0);

    -- Outputs (activation levels for each output fuzzy set)
    out_healthy_mf  : out signed(7 downto 0);
    out_mild_mf     : out signed(7 downto 0);
    out_moderate_mf : out signed(7 downto 0);
    out_severe_mf   : out signed(7 downto 0)
  );
end entity fuzzy_rule_base;

architecture behavioral of fuzzy_rule_base is
  -- Helper function for MIN operation (Mamdani inference)
  function fuzzy_min (a, b : signed) return signed is
  begin
    if a < b then
      return a;
    else
      return b;
    end if;
  end function fuzzy_min;

  -- Helper function for MAX operation (Mamdani aggregation)
  function fuzzy_max (a, b : signed) return signed is
  begin
    if a > b then
      return a;
    else
      return b;
    end if;
  end function fuzzy_max;

begin
  -- Initialize outputs to 0
  out_healthy_mf  <= (others => '0');
  out_mild_mf     <= (others => '0');
  out_moderate_mf <= (others => '0');
  out_severe_mf   <= (others => '0');

  -- Rule Base (Example rules, adjust as needed based on expert knowledge)
  -- Output: Healthy
  -- IF PPL is Low AND Delta Isc is Normal AND Delta Voc is Normal THEN Healthy
  out_healthy_mf <= fuzzy_max(out_healthy_mf, fuzzy_min(ppl_low_mf, fuzzy_min(disc_normal_mf, dvoc_normal_mf)));

  -- Output: Mild Hotspot
  -- IF PPL is Medium AND Delta Isc is Small AND Delta Voc is Normal THEN Mild
  out_mild_mf <= fuzzy_max(out_mild_mf, fuzzy_min(ppl_medium_mf, fuzzy_min(disc_small_mf, dvoc_normal_mf)));
  -- IF PPL is Low AND Delta Isc is Small AND Delta Voc is Reduced THEN Mild
  out_mild_mf <= fuzzy_max(out_mild_mf, fuzzy_min(ppl_low_mf, fuzzy_min(disc_small_mf, dvoc_reduced_mf)));

  -- Output: Moderate Hotspot
  -- IF PPL is High AND Delta Isc is Small AND Delta Voc is Normal THEN Moderate
  out_moderate_mf <= fuzzy_max(out_moderate_mf, fuzzy_min(ppl_high_mf, fuzzy_min(disc_small_mf, dvoc_normal_mf)));
  -- IF PPL is Medium AND Delta Isc is Significant AND Delta Voc is Normal THEN Moderate
  out_moderate_mf <= fuzzy_max(out_moderate_mf, fuzzy_min(ppl_medium_mf, fuzzy_min(disc_significant_mf, dvoc_normal_mf)));
  -- IF PPL is Medium AND Delta Isc is Small AND Delta Voc is Reduced THEN Moderate
  out_moderate_mf <= fuzzy_max(out_moderate_mf, fuzzy_min(ppl_medium_mf, fuzzy_min(disc_small_mf, dvoc_reduced_mf)));

  -- Output: Severe Hotspot
  -- IF PPL is High AND Delta Isc is Significant AND Delta Voc is Reduced THEN Severe
  out_severe_mf <= fuzzy_max(out_severe_mf, fuzzy_min(ppl_high_mf, fuzzy_min(disc_significant_mf, dvoc_reduced_mf)));
  -- IF PPL is High AND Delta Isc is Significant AND Delta Voc is Normal THEN Severe
  out_severe_mf <= fuzzy_max(out_severe_mf, fuzzy_min(ppl_high_mf, fuzzy_min(disc_significant_mf, dvoc_normal_mf)));
  -- IF PPL is Medium AND Delta Isc is Significant AND Delta Voc is Reduced THEN Severe
  out_severe_mf <= fuzzy_max(out_severe_mf, fuzzy_min(ppl_medium_mf, fuzzy_min(disc_significant_mf, dvoc_reduced_mf)));

end architecture behavioral;
