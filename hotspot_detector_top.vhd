library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Include the fixed-point package (assuming it's compiled first)
-- use work.fixed_point_pkg.all;

entity hotspot_detector_top is
  port (
    clk          : in  std_logic;
    reset        : in  std_logic;
    ppl_raw      : in  signed(15 downto 0); -- Raw PPL input (e.g., Q8.8 format)
    delta_isc_raw: in  signed(15 downto 0); -- Raw Delta Isc input (e.g., Q8.8 format)
    delta_voc_raw: in  signed(15 downto 0); -- Raw Delta Voc input (e.g., Q8.8 format)
    hotspot_idx  : out signed(15 downto 0)  -- Hotspot Severity Index (e.g., Q8.8 format)
  );
end entity hotspot_detector_top;

architecture structural of hotspot_detector_top is

  -- Signals for fuzzifier outputs
  signal ppl_low_mf_s, ppl_medium_mf_s, ppl_high_mf_s : signed(7 downto 0);
  signal disc_normal_mf_s, disc_small_mf_s, disc_significant_mf_s : signed(7 downto 0);
  signal dvoc_normal_mf_s, dvoc_reduced_mf_s : signed(7 downto 0);

  -- Signals for rule base outputs (activations for output fuzzy sets)
  signal out_healthy_mf_s, out_mild_mf_s, out_moderate_mf_s, out_severe_mf_s : signed(7 downto 0);

  -- Component declarations for the fuzzy modules
  component fuzzifier_ppl is
    port (
      ppl_in   : in  signed(15 downto 0);
      mf_low   : out signed(7 downto 0);
      mf_medium: out signed(7 downto 0);
      mf_high  : out signed(7 downto 0)
    );
  end component fuzzifier_ppl;

  component fuzzifier_delta_isc is
    port (
      delta_isc_in : in  signed(15 downto 0);
      mf_normal    : out signed(7 downto 0);
      mf_small     : out signed(7 downto 0);
      mf_significant: out signed(7 downto 0)
    );
  end component fuzzifier_delta_isc;

  component fuzzifier_delta_voc is
    port (
      delta_voc_in : in  signed(15 downto 0);
      mf_normal    : out signed(7 downto 0);
      mf_reduced   : out signed(7 downto 0)
    );
  end component fuzzifier_delta_voc;

  component fuzzy_rule_base is
    port (
      ppl_low_mf   : in signed(7 downto 0);
      ppl_medium_mf: in signed(7 downto 0);
      ppl_high_mf  : in signed(7 downto 0);
      disc_normal_mf    : in signed(7 downto 0);
      disc_small_mf     : in signed(7 downto 0);
      disc_significant_mf: in signed(7 downto 0);
      dvoc_normal_mf : in signed(7 downto 0);
      dvoc_reduced_mf: in signed(7 downto 0);
      out_healthy_mf  : out signed(7 downto 0);
      out_mild_mf     : out signed(7 downto 0);
      out_moderate_mf : out signed(7 downto 0);
      out_severe_mf   : out signed(7 downto 0)
    );
  end component fuzzy_rule_base;

  component defuzzifier is
    port (
      in_healthy_mf  : in signed(7 downto 0);
      in_mild_mf     : in signed(7 downto 0);
      in_moderate_mf : in signed(7 downto 0);
      in_severe_mf   : in signed(7 downto 0);
      hotspot_index  : out signed(15 downto 0)
    );
  end component defuzzifier;

begin

  -- Instantiate Fuzzifiers
  fuzz_ppl_inst : fuzzifier_ppl
    port map (
      ppl_in    => ppl_raw,
      mf_low    => ppl_low_mf_s,
      mf_medium => ppl_medium_mf_s,
      mf_high   => ppl_high_mf_s
    );

  fuzz_disc_inst : fuzzifier_delta_isc
    port map (
      delta_isc_in => delta_isc_raw,
      mf_normal    => disc_normal_mf_s,
      mf_small     => disc_small_mf_s,
      mf_significant => disc_significant_mf_s
    );

  fuzz_dvoc_inst : fuzzifier_delta_voc
    port map (
      delta_voc_in => delta_voc_raw,
      mf_normal    => dvoc_normal_mf_s,
      mf_reduced   => dvoc_reduced_mf_s
    );

  -- Instantiate Fuzzy Rule Base
  rule_base_inst : fuzzy_rule_base
    port map (
      ppl_low_mf    => ppl_low_mf_s,
      ppl_medium_mf => ppl_medium_mf_s,
      ppl_high_mf   => ppl_high_mf_s,
      disc_normal_mf     => disc_normal_mf_s,
      disc_small_mf      => disc_small_mf_s,
      disc_significant_mf => disc_significant_mf_s,
      dvoc_normal_mf  => dvoc_normal_mf_s,
      dvoc_reduced_mf => dvoc_reduced_mf_s,
      out_healthy_mf  => out_healthy_mf_s,
      out_mild_mf     => out_mild_mf_s,
      out_moderate_mf => out_moderate_mf_s,
      out_severe_mf   => out_severe_mf_s
    );

  -- Instantiate Defuzzifier
  defuzz_inst : defuzzifier
    port map (
      in_healthy_mf  => out_healthy_mf_s,
      in_mild_mf     => out_mild_mf_s,
      in_moderate_mf => out_moderate_mf_s,
      in_severe_mf   => out_severe_mf_s,
      hotspot_index  => hotspot_idx
    );

end architecture structural;
