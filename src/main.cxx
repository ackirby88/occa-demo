#include <iostream>
#include <unistd.h>
#include <occa.hpp>

int main(int argc, const char **argv) {
  /* create symbolic link for including headers in OKL files */
  std::cout << "OKL_DIR:" << OKL_DIR << std::endl;
  int errval = symlink(OKL_DIR "/okl","okl");
  if(errval && errno != EEXIST){
     printf("[ERROR] Issue with creating symbolic link for okl directory.\n"
            "        Error number: %d\n",errno);
  }

  int entries = 12;
  float *a  = new float[entries];
  float *b  = new float[entries];
  float *ab = new float[entries];

  for (int i = 0; i < entries; ++i) {
    a[i]  = i;
    b[i]  = 1 - i;
    ab[i] = 0;
  }

  occa::device device;
  occa::memory o_a, o_b, o_ab;
  occa::settings()["kernel/verbose"] = "verbose";

  device.setup({{"mode", "Serial"}});
  //---[ Device Setup ]-------------------------------------
  if(argc>1){
    switch(std::atoi(argv[1])){
      case(0):
        device.setup({
          {"mode", "Serial"}
        });
        break;
      case(1):
   	device.setup({
     	  {"mode"    , "OpenMP"},
     	  {"schedule", "compact"},
      	  {"chunk"   , 10},
    	});
        break;
      case(2):
	device.setup({
     	  {"mode"     , "CUDA"},
     	  {"device_id", 0},
   	});
  	break;
      case(3):
    	device.setup({
      	  {"mode"     , "HIP"},
      	  {"device_id", 0},
    	});
   	break;
      case(4):
   	device.setup({
      	  {"mode"       , "OpenCL"},
      	  {"platform_id", 0},
      	  {"device_id"  , 0},
    	});
   	break;
      case(5):
    	device.setup({
      	  {"mode"     , "Metal"},
      	  {"device_id", 0},
    	});
	break;
    }
  }
  //========================================================

  // Allocate memory on the device
  o_a = device.malloc<float>(entries);
  o_b = device.malloc<float>(entries);

  // We can also allocate memory without a dtype
  // WARNING: This will disable runtime type checking
  o_ab = device.malloc(entries * sizeof(float));

  // Compile the kernel at run-time
  occa::kernel addVectors = device.buildKernel("./okl/addVectors.okl","addVectors");

  // Copy memory to the device
  o_a.copyFrom(a);
  o_b.copyFrom(b);

  // Launch device kernel
  addVectors(entries, o_a, o_b, o_ab);

  // Copy result to the host
  o_ab.copyTo(ab);

  // Assert values
  for (int i = 0; i < entries; ++i) {
    std::cout << i << ": " << ab[i] << '\n';
  }
  for (int i = 0; i < entries; ++i) {
    if (!occa::areBitwiseEqual(ab[i], a[i] + b[i])) {
      throw 1;
    }
  }

  // Free host memory
  delete [] a;
  delete [] b;
  delete [] ab;

  return 0;
}
