module tb_arbiter_modport1;
  
  parameter N = 4;
  logic clk, reset;
  
  interface arbiter_if #(parameter N = 4)(input logic clk, reset);
    logic [N-1:0] req, grant;
    
    modport DUT(input clk, reset, req, output grant);
    modport TB(output req, input clk, reset, grant);
  endinterface
  
  arbiter_if #(N) arb_if(.clk(clk), .reset(reset));
  
  arbiter #(.N(N)) dut (.clk(arb_if.clk), .reset(arb_if.reset), .req(arb_if.req), .grant(arb_if.grant));
  
  initial
    clk = 0;
  always #5 clk = ~clk;
  
  initial
    begin
      reset = 1;
      #15 reset = 0;
    end
  
  program test(arbiter_if.TB tb_if);
    integer last_grant_ref;
    logic [N-1:0] exp_grant;
    
    task automatic ref_model(input logic [N-1:0] req_in,output logic [N-1:0] gnt_out);
      
      gnt_out = 0;
      
      for (int i = 0; i < N; i++) begin
        int idx = (last_grant_ref + 1 + i);
        if (idx >= N) idx -= N;
        if (req_in[idx]) begin
          gnt_out[idx] = 1;
          last_grant_ref = idx;
          return;
        end
      end
    endtask
    
    initial
      begin
        last_grant_ref = 0;
        @(negedge tb_if.reset);
        
        repeat (20) begin
          tb_if.req = $urandom_range(0, (1<<N)-1);
          @(posedge tb_if.clk);
          
          ref_model(tb_if.req, exp_grant);
          
          if (tb_if.grant !== exp_grant)
            $error("Mismatch! req=%b exp=%b got=%b", tb_if.req, exp_grant, tb_if.grant);
          else
            $display("PASS: req=%b grant=%b", tb_if.req, tb_if.grant);
        end
        
        $finish;
        
      end
  endprogram
  
  test t1 (arb_if);
  
endmodule