CXX ?= g++
CXXFLAGS += -O2 -std=c++11 $(shell fltk-config --cxxflags)
LDLIBS += $(shell fltk-config --ldflags)

all: iptvcenter
iptvcenter: src/iptvcenter.cpp
	$(CXX) $(CXXFLAGS) -o $@ $< $(LDLIBS)
clean:
	rm -f iptvcenter
