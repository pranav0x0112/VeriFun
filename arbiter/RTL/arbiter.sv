// Parameter Round Robin arbiter

module arbiter #(parameter int N = 4)(input logic clk, reset, input logic [N-1:0] req, output logic [N-1:0] grant);

  integer last_grant;

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin 
      last_grant <= 0;
      grant <= 0;
    end else begin
      grant <= 0;

      for(integer i = 0; i < N; i++) begin
        integer index;
        index = (last_grant + 1 + i);
        if(index >= N)
          index =  index - N;

        if (req[index]) begin
          grant[index] <= 1;
          last_grant <= index;
          break;
        end
      end
    end
  end
endmodule