#include <FL/Fl.H>
#include <FL/Fl_Window.H>
#include <FL/Fl_Box.H>
#include <FL/Fl_Button.H>
#include <FL/Fl_Hold_Browser.H>
#include <cstdlib>
#include <sys/stat.h>
#include <string>
#include <vector>

// Estructura para cada episodio
struct Episodio {
    std::string titulo;
    std::string url;
};

// Lista de episodios
std::vector<Episodio> capitulos = {
    { "Big Buck Bunny", "https://www.youtube.com/watch?v=YE7VzlLtp-4" },
    { "Capitulo 2", "https://ejemplo2.mp4" },
};

// Directorio de destino para descargas
const std::string dir_destino = "/home/tc/Videos/carpeta";

void play_cb(Fl_Widget*, void* data) {
    Fl_Hold_Browser* lista = (Fl_Hold_Browser*)data;
    int index = lista->value() - 1;
    if (index < 0 || index >= (int)capitulos.size()) return;

    std::string comando = "/usr/local/bin/yt360 \"" + capitulos[index].url + "\" &";
    system(comando.c_str());
}

void download_cb(Fl_Widget*, void* data) {
    Fl_Hold_Browser* lista = (Fl_Hold_Browser*)data;
    int index = lista->value() - 1;
    if (index < 0 || index >= (int)capitulos.size()) return;

    // Crear directorio si no existe
    mkdir("/home/tc/Videos", 0755);
    mkdir(dir_destino.c_str(), 0755);

    // Comando de descarga
    std::string comando = "xterm -e wget -c \"" + capitulos[index].url + "\" -P \"" + dir_destino + "\" &";
    system(comando.c_str());
}

int main(int argc, char **argv) {
    Fl_Window* win = new Fl_Window(584, 270, "Título");

    // Lista de capítulos
    Fl_Hold_Browser* lista = new Fl_Hold_Browser(10, 10, 405, 250);
    for (const auto& ep : capitulos) {
        lista->add(ep.titulo.c_str());
    }

    // Botón Play
    Fl_Button* play_btn = new Fl_Button(420, 10, 160, 40, "Reproducir");
    play_btn->callback(play_cb, (void*)lista);

    // Botón Download
    Fl_Button* download_btn = new Fl_Button(420, 60, 160, 40, "Descargar");
    download_btn->callback(download_cb, (void*)lista);

    win->end();
    win->show(argc, argv);
    return Fl::run();
}
