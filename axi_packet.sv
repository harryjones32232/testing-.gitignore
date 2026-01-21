package axi_packet;
  //Read output struct
  typedef struct 
  {
    logic[31:0] rdata;
    logic [1:0] rresp;
    logic rlast;
  }r_out;

//Memory read/write
typedef enum logic [1:0] {
	OFF,
  DISABLE,
	READ,
	WRITE
} memory_en_e;
  
typedef enum logic [1:0] {
	VALID_FIRST,
  READY_FIRST
}handshake_e;
  
endpackage 