module tb_arbiter_basic;
  
  parameter N = 4;
  logic clk, reset;
  logic [N-1:0] req, grant;
  
  arbiter # (.N(N)) dut (.clk(clk), .reset(reset), .req(req), .grant(grant));
  
  initial 
    clk = 0;
  always #5 clk = ~clk;
  
  initial
    begin
      reset = 1;
      req = 0;
      #15 reset = 0;
    end
  
  integer last_grant_ref;
  logic [N-1:0] exp_grant;
  
  task automatic ref_model(input logic [N-1:0] req_in, output logic [N-1:0] gnt_out);
    gnt_out = 0;
    for(int i = 0; i < N; i++)
      begin
        int idx = (last_grant_ref + 1 + i);
        if(idx >= N)
          idx = idx - N;
        if(req_in[idx])
          begin
            gnt_out[idx] = 1;
            last_grant_ref = idx;
            return;
          end
      end
  endtask
  
  initial
    begin
      last_grant_ref = 0;
      @(negedge reset);
      
      repeat(20)
        begin
          req = $urandom_range(0, (1<<N)-1);
          @(posedge clk);
          
          ref_model(req, exp_grant);
          
          if(grant !== exp_grant)
            begin
              $error("Mismatch! req=%b exp=%b got=%b", req, exp_grant, grant);
            end else
              begin
                $display("PASS: req=%b grant=%b", req, grant);
              end
        end
      $finish;
    end
endmodule
