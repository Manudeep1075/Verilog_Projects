`timescale 1ns/1ps
// ============================================================
//  Testbench — packet_parser
// ============================================================
module tb_packet_parser;

    reg        clk, rst_n;
    reg  [7:0] rx_data;
    reg        rx_valid, rx_last;
    wire       rx_ready;

    wire        ipv4_valid;
    wire [3:0]  ipv4_version, ipv4_ihl;
    wire [7:0]  ipv4_dscp_ecn, ipv4_ttl, ipv4_protocol;
    wire [15:0] ipv4_total_len, ipv4_id, ipv4_checksum;
    wire [2:0]  ipv4_flags;
    wire [12:0] ipv4_frag_off;
    wire [31:0] ipv4_src_addr, ipv4_dst_addr;

    wire        ipv6_valid;
    wire [3:0]  ipv6_version;
    wire [7:0]  ipv6_traffic_class, ipv6_next_header, ipv6_hop_limit;
    wire [19:0] ipv6_flow_label;
    wire [15:0] ipv6_payload_len;
    wire [127:0] ipv6_src_addr, ipv6_dst_addr;

    wire        parse_done;
    wire [1:0]  ip_version_out;
    wire        parse_error;

    packet_parser dut (
        .clk(clk), .rst_n(rst_n),
        .rx_data(rx_data), .rx_valid(rx_valid),
        .rx_last(rx_last), .rx_ready(rx_ready),
        .ipv4_valid(ipv4_valid),
        .ipv4_version(ipv4_version), .ipv4_ihl(ipv4_ihl),
        .ipv4_dscp_ecn(ipv4_dscp_ecn), .ipv4_total_len(ipv4_total_len),
        .ipv4_id(ipv4_id), .ipv4_flags(ipv4_flags),
        .ipv4_frag_off(ipv4_frag_off), .ipv4_ttl(ipv4_ttl),
        .ipv4_protocol(ipv4_protocol), .ipv4_checksum(ipv4_checksum),
        .ipv4_src_addr(ipv4_src_addr), .ipv4_dst_addr(ipv4_dst_addr),
        .ipv6_valid(ipv6_valid),
        .ipv6_version(ipv6_version),
        .ipv6_traffic_class(ipv6_traffic_class),
        .ipv6_flow_label(ipv6_flow_label),
        .ipv6_payload_len(ipv6_payload_len),
        .ipv6_next_header(ipv6_next_header),
        .ipv6_hop_limit(ipv6_hop_limit),
        .ipv6_src_addr(ipv6_src_addr), .ipv6_dst_addr(ipv6_dst_addr),
        .parse_done(parse_done),
        .ip_version_out(ip_version_out),
        .parse_error(parse_error)
    );

    always #5 clk = ~clk;

    // Send one byte, assert rx_last on final byte
    task send_byte;
        input [7:0] d;
        input       last;
        begin
            @(negedge clk);       // drive on falling edge
            rx_data  = d;
            rx_valid = 1'b1;
            rx_last  = last;
            @(posedge clk);       // DUT samples on rising edge
            #1;
            rx_valid = 1'b0;
            rx_last  = 1'b0;
        end
    endtask

    reg [7:0] pkt [0:79];
    integer   plen, i;

    task send_packet;
        input integer len;
        integer j;
        begin
            for (j = 0; j < len; j = j + 1)
                send_byte(pkt[j], (j == len - 1));
        end
    endtask

    // Wait up to N cycles for a condition
    task wait_for_valid;
        input integer max_cycles;
        integer k;
        begin
            k = 0;
            while (!ipv4_valid && !ipv6_valid && k < max_cycles) begin
                @(posedge clk); #1;
                k = k + 1;
            end
        end
    endtask

    initial begin
        clk = 0; rst_n = 0;
        rx_valid = 0; rx_last = 0; rx_data = 0;
        repeat(4) @(posedge clk);
        rst_n = 1;
        repeat(2) @(posedge clk);

        // ═══════════════════════════════════════════════════
        //  TEST 1 — IPv4
        //  Src: 192.168.1.1  Dst: 10.0.0.1
        //  Proto: 6 (TCP)  TTL: 64
        // ═══════════════════════════════════════════════════
        // Ethernet header (14 bytes)
        pkt[0]=8'hff;
      	pkt[1]=8'hff;
      	pkt[2]=8'hff;
        pkt[3]=8'hff;
      	pkt[4]=8'hff;
      	pkt[5]=8'hff;   // DST MAC
        pkt[6]=8'h00;
      	pkt[7]=8'h11;
      	pkt[8]=8'h22;
        pkt[9]=8'h33;
      	pkt[10]=8'h44;
      	pkt[11]=8'h55;  // SRC MAC
        pkt[12]=8'h08;
      	pkt[13]=8'h00;                 // EtherType = IPv4
        // IPv4 header (20 bytes)
        pkt[14]=8'h45;                                 // ver=4, IHL=5
        pkt[15]=8'h00;                                 // DSCP/ECN
        pkt[16]=8'h00;
      	pkt[17]=8'h28;                 // total len = 40
        pkt[18]=8'h12;
      	pkt[19]=8'h34;                 // ID
        pkt[20]=8'h40;
      	pkt[21]=8'h00;                 // flags=DF, frag=0
        pkt[22]=8'h40;                                 // TTL=64
        pkt[23]=8'h06;                                 // Protocol=TCP
        pkt[24]=8'hb8;
      	pkt[25]=8'h61;                 // checksum
        pkt[26]=8'hc0;
      	pkt[27]=8'ha8;
      	pkt[28]=8'h01;
      	pkt[29]=8'h01; // 192.168.1.1
        pkt[30]=8'h0a;
      	pkt[31]=8'h00;
      	pkt[32]=8'h00;
      	pkt[33]=8'h01; // 10.0.0.1
        plen = 34;

        $display("=== Sending IPv4 packet ===");
        send_packet(plen);
        wait_for_valid(20);

        if (ipv4_valid) begin
            $display("PASS: IPv4 valid asserted");
            $display("  Version   : %0d",   ipv4_version);
            $display("  IHL       : %0d",   ipv4_ihl);
            $display("  DSCP/ECN  : 0x%02h", ipv4_dscp_ecn);
            $display("  Total Len : %0d",   ipv4_total_len);
            $display("  ID        : 0x%04h", ipv4_id);
            $display("  Flags     : %03b",  ipv4_flags);
            $display("  Frag Off  : %0d",   ipv4_frag_off);
            $display("  TTL       : %0d",   ipv4_ttl);
            $display("  Protocol  : %0d",   ipv4_protocol);
            $display("  Checksum  : 0x%04h", ipv4_checksum);
            $display("  Src       : %0d.%0d.%0d.%0d",
                ipv4_src_addr[31:24], ipv4_src_addr[23:16],
                ipv4_src_addr[15:8],  ipv4_src_addr[7:0]);
            $display("  Dst       : %0d.%0d.%0d.%0d",
                ipv4_dst_addr[31:24], ipv4_dst_addr[23:16],
                ipv4_dst_addr[15:8],  ipv4_dst_addr[7:0]);
        end else begin
            $display("FAIL: IPv4 valid not asserted");
        end

        repeat(5) @(posedge clk);

        // ═══════════════════════════════════════════════════
        //  TEST 2 — IPv6
        //  Src: 2001:db8::1   Dst: 2001:db8::2
        //  Next Header: 0x3a (ICMPv6)  Hop Limit: 255
        // ═══════════════════════════════════════════════════
        // Ethernet header
        pkt[0]=8'hff; pkt[1]=8'hff; pkt[2]=8'hff;
        pkt[3]=8'hff; pkt[4]=8'hff; pkt[5]=8'hff;
        pkt[6]=8'haa; pkt[7]=8'hbb; pkt[8]=8'hcc;
        pkt[9]=8'hdd; pkt[10]=8'hee; pkt[11]=8'hff;
        pkt[12]=8'h86; pkt[13]=8'hDD;                 // EtherType = IPv6
        // IPv6 fixed header (40 bytes)
        pkt[14]=8'h60; pkt[15]=8'h00;                 // ver=6, TC=0, flow[19:16]=0
        pkt[16]=8'h00; pkt[17]=8'h00;                 // flow[15:0]
        pkt[18]=8'h00; pkt[19]=8'h14;                 // payload len = 20
        pkt[20]=8'h3a;                                 // Next Header = ICMPv6
        pkt[21]=8'hff;                                 // Hop Limit = 255
        // src = 2001:0db8:0000:0000:0000:0000:0000:0001
        pkt[22]=8'h20; pkt[23]=8'h01; pkt[24]=8'h0d; pkt[25]=8'hb8;
        pkt[26]=8'h00; pkt[27]=8'h00; pkt[28]=8'h00; pkt[29]=8'h00;
        pkt[30]=8'h00; pkt[31]=8'h00; pkt[32]=8'h00; pkt[33]=8'h00;
        pkt[34]=8'h00; pkt[35]=8'h00; pkt[36]=8'h00; pkt[37]=8'h01;
        // dst = 2001:0db8:0000:0000:0000:0000:0000:0002
        pkt[38]=8'h20; pkt[39]=8'h01; pkt[40]=8'h0d; pkt[41]=8'hb8;
        pkt[42]=8'h00; pkt[43]=8'h00; pkt[44]=8'h00; pkt[45]=8'h00;
        pkt[46]=8'h00; pkt[47]=8'h00; pkt[48]=8'h00; pkt[49]=8'h00;
        pkt[50]=8'h00; pkt[51]=8'h00; pkt[52]=8'h00; pkt[53]=8'h02;
        plen = 54;

        $display("\n=== Sending IPv6 packet ===");
        send_packet(plen);
        wait_for_valid(20);

        if (ipv6_valid) begin
            $display("PASS: IPv6 valid asserted");
            $display("  Version       : %0d",   ipv6_version);
            $display("  Traffic Class : 0x%02h", ipv6_traffic_class);
            $display("  Flow Label    : 0x%05h", ipv6_flow_label);
            $display("  Payload Len   : %0d",   ipv6_payload_len);
            $display("  Next Header   : 0x%02h", ipv6_next_header);
            $display("  Hop Limit     : %0d",   ipv6_hop_limit);
            $display("  Src : %04h:%04h:%04h:%04h:%04h:%04h:%04h:%04h",
                ipv6_src_addr[127:112], ipv6_src_addr[111:96],
                ipv6_src_addr[95:80],   ipv6_src_addr[79:64],
                ipv6_src_addr[63:48],   ipv6_src_addr[47:32],
                ipv6_src_addr[31:16],   ipv6_src_addr[15:0]);
            $display("  Dst : %04h:%04h:%04h:%04h:%04h:%04h:%04h:%04h",
                ipv6_dst_addr[127:112], ipv6_dst_addr[111:96],
                ipv6_dst_addr[95:80],   ipv6_dst_addr[79:64],
                ipv6_dst_addr[63:48],   ipv6_dst_addr[47:32],
                ipv6_dst_addr[31:16],   ipv6_dst_addr[15:0]);
        end else begin
            $display("FAIL: IPv6 valid not asserted");
        end

        repeat(5) @(posedge clk);
        $display("\nSimulation complete.");
        $finish;
    end

endmodule