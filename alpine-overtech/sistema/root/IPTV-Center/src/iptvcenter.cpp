#include <FL/Fl.H>
#include <FL/Fl_Button.H>
#include <FL/Fl_Input.H>
#include <FL/Fl_Double_Window.H>
#include <FL/Fl_Hold_Browser.H>
#include <FL/fl_ask.H>
#include <algorithm>
#include <cctype>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <cstdlib>

struct Channel { std::string name, url; };
static std::vector<Channel> channels;
static Fl_Input *source_input, *search_input;
static Fl_Hold_Browser *browser;

static std::string trim(std::string s) {
  while (!s.empty() && std::isspace((unsigned char)s.front())) s.erase(s.begin());
  while (!s.empty() && std::isspace((unsigned char)s.back())) s.pop_back();
  return s;
}

static std::string shell_quote(const std::string &s) {
  std::string q = "'";
  for (char c : s) q += (c == '\'' ? "'\\''" : std::string(1, c));
  return q + "'";
}

static void refresh_list() {
  browser->clear();
  std::string needle = search_input->value();
  std::transform(needle.begin(), needle.end(), needle.begin(), ::tolower);
  for (size_t i = 0; i < channels.size(); ++i) {
    std::string n = channels[i].name;
    std::transform(n.begin(), n.end(), n.begin(), ::tolower);
    if (needle.empty() || n.find(needle) != std::string::npos) {
      std::ostringstream row; row << (i + 1) << ". " << channels[i].name;
      browser->add(row.str().c_str(), (void *)(i + 1));
    }
  }
}

static bool parse_m3u(const char *path) {
  std::ifstream f(path); if (!f) return false;
  channels.clear(); std::string line, pending;
  while (std::getline(f, line)) {
    line = trim(line);
    if (line.rfind("#EXTINF:", 0) == 0) {
      size_t comma = line.find_last_of(',');
      pending = comma == std::string::npos ? "Canal" : trim(line.substr(comma + 1));
    } else if (!line.empty() && line[0] != '#') {
      channels.push_back({pending.empty() ? line : pending, line}); pending.clear();
    }
  }
  refresh_list(); return !channels.empty();
}

static void load_cb(Fl_Widget *, void *) {
  std::string src = trim(source_input->value());
  if (src.empty()) { fl_alert("Pegá una URL o una ruta M3U."); return; }
  const char *tmp = "/tmp/iptvcenter.m3u";
  std::string path = src;
  if (src.rfind("http://",0)==0 || src.rfind("https://",0)==0) {
    std::string cmd = "wget -q -O " + shell_quote(tmp) + " " + shell_quote(src);
    if (std::system(cmd.c_str()) != 0) { fl_alert("No se pudo descargar la lista."); return; }
    path = tmp;
  }
  if (!parse_m3u(path.c_str())) fl_alert("La lista no contiene canales válidos.");
}

static void search_cb(Fl_Widget *, void *) { refresh_list(); }

static void play_cb(Fl_Widget *, void *) {
  int row = browser->value();
  if (!row) { fl_alert("Elegí un canal."); return; }
  size_t idx = (size_t)browser->data(row) - 1;
  if (idx >= channels.size()) return;
  std::string cmd = "/usr/local/bin/iptv-play " + shell_quote(channels[idx].url) + " >/tmp/iptv-play.log 2>&1 &";
  std::system(cmd.c_str());
}

int main() {
  Fl_Double_Window win(800, 480, "IPTV Center 0.1-experimento");
  source_input = new Fl_Input(90, 18, 580, 42, "Lista:");
  source_input->value("https://iptv-org.github.io/iptv/languages/spa.m3u");
  Fl_Button load(680, 18, 105, 42, "CARGAR"); load.callback(load_cb);
  search_input = new Fl_Input(90, 70, 695, 40, "Buscar:"); search_input->when(FL_WHEN_CHANGED); search_input->callback(search_cb);
  browser = new Fl_Hold_Browser(15, 125, 770, 285); browser->textsize(22);
  Fl_Button play(250, 420, 300, 48, "ABRIR EN VLC"); play.callback(play_cb);
  win.resizable(browser); win.end(); win.show(); return Fl::run();
}
