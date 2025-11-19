//
//  sf_decrunch.c
//  sf_decrunch
//
//  Created by everything8215 on 7/28/20.
//  (everything8215@gmail.com)
//

#include <stdio.h>
#include <stdlib.h>

// 64k should be enough for anything
unsigned char decru_src[0x10000]; // source buffer
unsigned char decru_dest[0x10000]; // destination buffer
size_t decru_s = 0; // source pointer
size_t decru_d; // destination pointer
size_t d_length = 0; // length of decrunched data

size_t decru_buffer; // 32-bit buffer
int decru_b = 0; // buffer bit offset

void put_byte(unsigned char byte) {
    if (decru_d == 0) return;
    decru_dest[--decru_d] = byte;
}

void refill_buffer() {
    decru_buffer = 0;
    decru_b = 0;
    
    if (decru_s == 0) return;
    decru_buffer = decru_src[--decru_s];
    decru_b += 8;
    
    if (decru_s == 0) return;
    decru_buffer |= decru_src[--decru_s] * 256;
    decru_b += 8;
    
    if (decru_s == 0) return;
    decru_buffer |= decru_src[--decru_s] * (256*256);
    decru_b += 8;
    
    if (decru_s == 0) return;
    decru_buffer |= decru_src[--decru_s] * (256*256*256);
    decru_b += 8;
}

void init_buffer() {
    refill_buffer();
    unsigned int mask = 1;
    decru_b = 1;
    while (decru_buffer & ~mask) {
        mask <<= 1;
        mask |= 1;
        decru_b++;
    }
    
    // mask off the last bit
    decru_buffer &= (mask >> 1);
    decru_b--;
}

int get_bits(int n) {
    int bits = 0;
    if (n > decru_b) {
        n -= decru_b;
        bits = get_bits(decru_b);
        refill_buffer();
    }
    for (int i = 0; i < n; i++) {
        bits <<= 1;
        bits |= decru_buffer & 1;
        decru_buffer >>= 1;
    }
    decru_b -= n;
    return bits;
}

void decrunch_put_raw(int run) {
    // write uncompressed bytes
    while (run--) put_byte(get_bits(8) & 0xFF);
}

void decrunch_put_lzw(int run, int offset) {
    // write bytes from destination buffer (lzw)
    while (run--) put_byte(decru_dest[(long)decru_d + offset - 1]);
}

void decrunch_lzw() {
    int control = get_bits(2);
    int run = 0;
    int offset = -1;
    
    if (control == 0) {
        // comx10 (run is 2 bytes)
        run = 2;
        offset = get_bits(8);
        
    } else if (control == 1) {
        // com1xx (run is 3 bytes)
        run = 3;
        if (get_bits(1)) {
            offset = get_bits(8);
        } else {
            offset = get_bits(14);
        }
        
    } else if (control == 2) {
        // fill (run is 4 bytes)
        run = 4;
        
    } else if ((control = get_bits(2)) < 2) {
        // run is 5 or 6 bytes
        run = control + 5;
        
    } else if (control == 2) {
        // com11x (run is 7 to 10 bytes)
        run = get_bits(2) + 7;

    } else if (control == 3) {
        // com111 (run is 11 to 255 bytes)
        run = get_bits(8);

    }

    if (run > 3) {
        // fill
        if (!get_bits(1)) {
            offset = get_bits(16);
        } else if (get_bits(1)) {
            offset = get_bits(8);
        } else {
            offset = get_bits(12);
        }
    }

    decrunch_put_lzw(run, offset);
}

void decrunch() {

    // get the decrunched length
    d_length |= decru_src[--decru_s];
    d_length |= decru_src[--decru_s] * 256;
    decru_s -= 2; // skip two bytes
    decru_d = d_length;

    // initialize the bit buffer
    init_buffer();
    
    while (decru_d) {
        int run = get_bits(3);
        if (run == 0) {
            // compressed, fall through to below
        
        } else if (run < 7) {
            // copy 1 to 6 bytes
            decrunch_put_raw(run);

        } else if (!get_bits(1)) {
            // copy 7 to 22 bytes
            decrunch_put_raw(get_bits(4) + 7);

        } else if ((run = get_bits(10))) {
            // copy up to 0x3FF bytes
            decrunch_put_raw(run);

        } else {
            // copy up to 0x3FFFF bytes
            decrunch_put_raw(get_bits(18));

        }
        decrunch_lzw();
    }
}

#ifdef ROBFX
int sfdecrunch_main(int argc, char** argv)
#else
int main(int argc, const char* argv[])
#endif
{
    // print help message
    if (argc < 3) {
        puts(
            "sf_decrunch v0.01\n"
            "Decompression utility for Star Fox / Star Fox 2\n"
            "by everything8215 (everything8215@gmail.com)\n"
            "usage: sf_decrunch input.ccr [offset] output.cgx\n"
            "offset is END of crunched data (defaults to end of file)\n"
        );
        return 0;
    }
    
    const char* i_filename = argv[1];
    const char* o_filename;
    
    //parse arguments
    if (argc == 4) {
        decru_s = strtoul(argv[2], NULL, 0);
        o_filename = argv[3];
    } else {
        o_filename = argv[2];
    }

    FILE* i_file = fopen(i_filename, "rb");
    if (!i_file) {
        printf("error opening input file: %s\n", i_filename);
        return 0;
    }

    // get data offset (end of data)
    if (!decru_s) {
        fseek(i_file, 0, SEEK_END);
        decru_s = (size_t)ftell(i_file);
    }
    
    // copy file to source buffer
    if (decru_s > 0x10000) {
        fseek(i_file, (long)(decru_s - 0x10000), SEEK_SET);
        fread(decru_src, 1, 0x10000, i_file);
        decru_s = 0x10000;
    } else {
        fseek(i_file, 0, SEEK_SET);
        fread(decru_src, 1, decru_s, i_file);
    }
    fclose(i_file);

    // decrunch the data
    decrunch();

    // write output file
    FILE* o_file = fopen(o_filename, "wb");
    fwrite(decru_dest, 1, d_length, o_file);
    fclose(o_file);

    return 0;
}
