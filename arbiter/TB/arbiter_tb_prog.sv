module tb_arbiter_prog;

  parameter N = 4;
  logic clk, reset;
  logic [N-1:0] req, grant;

  // DUT
  arbiter #(.N(N)) dut (
    .clk(clk),
    .reset(reset),
    .req(req),
    .grant(grant)
  );

  // clock
  initial clk = 0;
  always #5 clk = ~clk;

  // reset
  initial begin
    reset = 1;
    req   = 0;
    #15 reset = 0;
  end

  // -----------------------------
  // Program block
  // -----------------------------
  program test;
    integer last_grant_ref;
    logic [N-1:0] exp_grant;
    integer i, idx;  // declare loop variables here

    // reference model
    task automatic ref_model(input logic [N-1:0] req_in, output logic [N-1:0] gnt_out);
      gnt_out = 0;
      for (i = 0; i < N; i = i + 1) begin
        idx = (last_grant_ref + 1 + i);
        if (idx >= N) idx = idx - N;
        if (req_in[idx]) begin
          gnt_out[idx] = 1;
          last_grant_ref = idx;
          return;
        end
      end
    endtask

    // stimulus + check
    initial begin
      last_grant_ref = 0;
      @(negedge reset);

      repeat (20) begin
        req = logic'($urandom_range(0, (1<<N)-1));
        @(posedge clk);

        ref_model(req, exp_grant);

        // avoid race with DUT update
        #1;
        if (grant !== exp_grant) begin
          $error("Mismatch! req=%b exp=%b got=%b", req, exp_grant, grant);
        end else begin
          $display("PASS: req=%b grant=%b", req, grant);
        end
      end

      $finish;
    end
  endprogram

endmodule