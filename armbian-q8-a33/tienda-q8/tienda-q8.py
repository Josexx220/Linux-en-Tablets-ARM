#!/usr/bin/env python3
"""Tienda Q8 v1: catálogo gráfico con APT restringido para Armbian armhf."""

import fcntl
import logging
import os
import subprocess
import sys
import threading

import gi

gi.require_version("Gtk", "3.0")
from gi.repository import Gdk, GLib, Gtk


APP_DIR = os.path.expanduser("~/.local/share/tienda-q8")
LOG_FILE = os.path.join(APP_DIR, "tienda-q8.log")
HELPER = "/usr/local/sbin/tienda-q8-apt"
STATE_FILE = "/var/lib/tienda-q8/installed-by-store"

os.makedirs(APP_DIR, exist_ok=True)
logging.basicConfig(
    filename=LOG_FILE,
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(message)s",
)


CSS = b"""
* {
    font-family: DejaVu Sans;
    color: #eeeeee;
}

window,
#store-root,
#store-content,
#app-scroll,
#app-scroll viewport {
    background: #090b0d;
}

#store-top {
    background: #101316;
    border-bottom: 2px solid #f36c21;
    min-height: 48px;
}

#store-brand {
    color: #f36c21;
    font-size: 18px;
    font-weight: bold;
}

#store-subtitle,
#result-count,
#package-name,
#store-status {
    color: #8b8f93;
}

#close-button,
#refresh-button,
#update-button,
#return-button,
.category-button,
.action-button {
    background: #181c20;
    border: 1px solid #30353a;
    border-radius: 4px;
    box-shadow: none;
    text-shadow: none;
}

#close-button:hover,
#refresh-button:hover,
#update-button:hover,
#return-button:hover,
.category-button:hover,
.action-button:hover {
    background: #272c31;
    border-color: #33383d;
}

#close-button {
    min-width: 44px;
    min-height: 36px;
    color: #ff7426;
    font-weight: bold;
}

#refresh-button,
#update-button {
    min-height: 36px;
    padding-left: 14px;
    padding-right: 14px;
}

#update-button,
#return-button {
    background: #f36c21;
    border-color: #f36c21;
    color: #090b0d;
    font-weight: bold;
}

#update-button label,
#return-button label {
    color: #090b0d;
    font-weight: bold;
}

#category-panel {
    background: #101316;
    border-right: 1px solid #30353a;
}

.category-button {
    min-height: 38px;
    padding: 4px 8px;
}

.category-active,
.category-active:hover {
    background: #f36c21;
    border-color: #f36c21;
}

.category-active label {
    color: #090b0d;
    font-weight: bold;
}

#search-entry {
    min-height: 38px;
    padding: 0 12px;
    background: #0b0e11;
    color: #eeeeee;
    border: 1px solid #30353a;
    border-radius: 4px;
    caret-color: #ff7426;
}

#search-entry:focus {
    border-color: #f36c21;
}

#app-card {
    background: #181c20;
    border: 1px solid #30353a;
    border-radius: 5px;
    padding: 9px;
}

#app-card:hover {
    background: #1d2227;
    border-color: #33383d;
}

#app-name {
    color: #eeeeee;
    font-size: 15px;
    font-weight: bold;
}

#app-description {
    color: #b8bbbe;
}

#installed-state {
    color: #ff7426;
    font-weight: bold;
}

#available-state {
    color: #8b8f93;
    font-weight: bold;
}

.action-button {
    min-width: 105px;
    min-height: 40px;
}

.action-button:disabled,
.action-button:disabled label {
    background: #101316;
    color: #8b8f93;
}

#store-bottom {
    background: #101316;
    border-top: 1px solid #30353a;
    min-height: 38px;
}

#mode-badge {
    color: #ff7426;
    font-weight: bold;
}

#operation-page {
    background: #0b0e11;
    padding: 16px;
}

#operation-title {
    color: #f36c21;
    font-size: 19px;
    font-weight: bold;
}

#operation-subtitle,
#operation-result {
    color: #eeeeee;
}

#operation-log,
#operation-log text,
#operation-scroll,
#operation-scroll viewport {
    background: #090b0d;
    color: #b8bbbe;
    font-family: DejaVu Sans Mono;
}

#operation-scroll {
    border: 1px solid #30353a;
}

#operation-progress trough {
    background: #181c20;
    border: 1px solid #30353a;
    min-height: 18px;
}

#operation-progress progress {
    background: #f36c21;
}

dialog,
dialog box {
    background: #101316;
}

scrollbar slider {
    background: #f36c21;
    min-width: 12px;
    min-height: 36px;
    border-radius: 6px;
}

scrollbar trough {
    background: #101316;
}
"""


CATEGORIES = [
    ("Todas", "view-grid-symbolic"),
    ("Juegos", "applications-games"),
    ("Emuladores", "input-gaming-symbolic"),
    ("Multimedia", "applications-multimedia"),
    ("Internet", "web-browser-symbolic"),
    ("Oficina", "x-office-document-symbolic"),
    ("Archivos", "folder-symbolic"),
    ("Gráficos", "applications-graphics"),
    ("Utilidades", "applications-utilities"),
]


CATALOG = [
    ("Juegos", "GNOME Minas", "gnome-mines", "Buscaminas táctil, sencillo y liviano.", False),
    ("Juegos", "GNOME Sudoku", "gnome-sudoku", "Sudoku gráfico con varios niveles.", False),
    ("Juegos", "LBreakout2", "lbreakout2", "Juego clásico de romper bloques.", False),
    ("Juegos", "Juegos del Pingüino", "ace-of-penguins", "Colección de juegos de cartas y tablero.", False),
    ("Emuladores", "DOSBox", "dosbox", "Emulador de juegos y programas de MS-DOS.", True),
    ("Emuladores", "ScummVM", "scummvm", "Aventuras gráficas clásicas.", True),
    ("Emuladores", "Stella", "stella", "Emulador de Atari 2600 con interfaz gráfica.", False),
    ("Emuladores", "Mednafen", "mednafen", "Emulador multisistema para consolas clásicas.", False),
    ("Multimedia", "MPV", "mpv", "Reproductor de audio y video eficiente.", True),
    ("Multimedia", "Parole", "parole", "Reproductor gráfico simple para video y audio.", False),
    ("Internet", "Dillo", "dillo", "Navegador ultraliviano para páginas sencillas.", True),
    ("Internet", "NetSurf", "netsurf-gtk", "Navegador liviano con interfaz GTK.", True),
    ("Internet", "Transmission", "transmission-gtk", "Cliente BitTorrent gráfico.", False),
    ("Internet", "Claws Mail", "claws-mail", "Cliente de correo electrónico liviano.", False),
    ("Oficina", "AbiWord", "abiword", "Procesador de textos liviano.", True),
    ("Oficina", "Gnumeric", "gnumeric", "Planilla de cálculo rápida y completa.", True),
    ("Oficina", "Evince", "evince", "Visor de documentos PDF.", True),
    ("Oficina", "Mousepad", "mousepad", "Editor de texto gráfico y sencillo.", False),
    ("Archivos", "PCManFM", "pcmanfm", "Administrador de archivos del entorno Q8.", True),
    ("Archivos", "Xarchiver", "xarchiver", "Crear y abrir archivos comprimidos.", False),
    ("Archivos", "Catfish", "catfish", "Buscar rápidamente archivos y carpetas.", False),
    ("Gráficos", "mtPaint", "mtpaint", "Editor liviano de imágenes y dibujos.", False),
    ("Gráficos", "GPicView", "gpicview", "Visor de imágenes rápido y pequeño.", False),
    ("Utilidades", "Calculadora", "galculator", "Calculadora gráfica liviana.", False),
    ("Utilidades", "Administrador de tareas", "xfce4-taskmanager", "Control de procesos y memoria.", True),
    ("Utilidades", "Teclado en pantalla", "onboard", "Teclado táctil integrado en Q8 Shell.", True),
]


class TiendaQ8(Gtk.Window):
    def __init__(self):
        super().__init__(title="Tienda Q8")
        self.set_name("store-window")
        self.set_default_size(940, 520)
        self.set_resizable(False)
        self.set_decorated(False)
        self.set_position(Gtk.WindowPosition.CENTER)
        self.connect("destroy", Gtk.main_quit)
        self.connect("delete-event", self.on_delete_event)

        provider = Gtk.CssProvider()
        provider.load_from_data(CSS)
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(),
            provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION,
        )

        self.category = "Todas"
        self.category_buttons = {}
        self.installed = set()
        self.managed = set()
        self.operation_running = False

        root = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        root.set_name("store-root")
        self.add(root)

        root.pack_start(self.build_header(), False, False, 0)

        self.main_stack = Gtk.Stack()
        self.main_stack.set_transition_type(Gtk.StackTransitionType.CROSSFADE)
        self.main_stack.set_transition_duration(180)
        root.pack_start(self.main_stack, True, True, 0)

        body = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        body.set_name("store-content")
        body.pack_start(self.build_categories(), False, False, 0)
        body.pack_start(self.build_catalog_area(), True, True, 0)

        self.main_stack.add_named(body, "catalog")
        self.main_stack.add_named(self.build_operation_page(), "operation")
        self.main_stack.set_visible_child_name("catalog")
        root.pack_end(self.build_footer(), False, False, 0)

        self.refresh_status()

    def build_header(self):
        header = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        header.set_name("store-top")
        header.set_border_width(6)

        brand = Gtk.Label(label="TIENDA Q8")
        brand.set_name("store-brand")
        brand.set_xalign(0)
        header.pack_start(brand, False, False, 8)

        subtitle = Gtk.Label(label="Software liviano para tu tablet")
        subtitle.set_name("store-subtitle")
        subtitle.set_xalign(0)
        header.pack_start(subtitle, False, False, 4)

        header.pack_start(Gtk.Label(), True, True, 0)

        self.refresh_button = Gtk.Button(label="↻ Estado")
        self.refresh_button.set_name("refresh-button")
        self.refresh_button.set_tooltip_text(
            "Volver a comprobar qué aplicaciones están instaladas"
        )
        self.refresh_button.connect("clicked", self.refresh_status)
        header.pack_start(self.refresh_button, False, False, 0)

        self.update_button = Gtk.Button(label="Actualizar APT")
        self.update_button.set_name("update-button")
        self.update_button.set_tooltip_text(
            "Actualizar solamente la información de paquetes"
        )
        self.update_button.connect("clicked", self.request_update)
        header.pack_start(self.update_button, False, False, 0)

        self.close_button = Gtk.Button(label="✕")
        self.close_button.set_name("close-button")
        self.close_button.set_tooltip_text("Cerrar Tienda Q8")
        self.close_button.connect("clicked", lambda *_: self.destroy())
        header.pack_start(self.close_button, False, False, 0)
        return header

    def build_categories(self):
        panel = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=3)
        panel.set_name("category-panel")
        panel.set_size_request(168, -1)
        panel.set_border_width(7)

        for name, icon_name in CATEGORIES:
            button = Gtk.Button()
            button.get_style_context().add_class("category-button")
            button.set_size_request(-1, 39)

            line = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
            line.set_halign(Gtk.Align.START)
            icon = Gtk.Image.new_from_icon_name(icon_name, Gtk.IconSize.BUTTON)
            icon.set_pixel_size(20)
            line.pack_start(icon, False, False, 0)
            line.pack_start(Gtk.Label(label=name), False, False, 0)
            button.add(line)
            button.connect("clicked", self.select_category, name)
            panel.pack_start(button, False, False, 0)
            self.category_buttons[name] = button

        self.category_buttons["Todas"].get_style_context().add_class("category-active")
        return panel

    def build_catalog_area(self):
        area = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        area.set_border_width(8)

        search_line = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        self.search = Gtk.Entry()
        self.search.set_name("search-entry")
        self.search.set_placeholder_text("Buscar aplicación o paquete…")
        self.search.set_icon_from_icon_name(
            Gtk.EntryIconPosition.PRIMARY,
            "system-search-symbolic",
        )
        self.search.connect("changed", lambda *_: self.render_catalog())
        search_line.pack_start(self.search, True, True, 0)

        self.result_count = Gtk.Label()
        self.result_count.set_name("result-count")
        search_line.pack_start(self.result_count, False, False, 5)
        area.pack_start(search_line, False, False, 0)

        scroll = Gtk.ScrolledWindow()
        scroll.set_name("app-scroll")
        scroll.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        scroll.set_overlay_scrolling(False)

        self.list_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        self.list_box.set_border_width(2)
        scroll.add_with_viewport(self.list_box)
        area.pack_start(scroll, True, True, 0)
        return area

    def build_footer(self):
        footer = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        footer.set_name("store-bottom")
        footer.set_border_width(7)

        self.status = Gtk.Label(label="Comprobando aplicaciones instaladas…")
        self.status.set_name("store-status")
        self.status.set_xalign(0)
        footer.pack_start(self.status, True, True, 4)

        mode = Gtk.Label(label="APT SEGURO ACTIVO")
        mode.set_name("mode-badge")
        footer.pack_end(mode, False, False, 5)
        return footer

    def build_operation_page(self):
        page = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=9)
        page.set_name("operation-page")
        page.set_border_width(14)

        self.operation_title = Gtk.Label(label="OPERACIÓN APT")
        self.operation_title.set_name("operation-title")
        self.operation_title.set_xalign(0)
        page.pack_start(self.operation_title, False, False, 0)

        self.operation_subtitle = Gtk.Label()
        self.operation_subtitle.set_name("operation-subtitle")
        self.operation_subtitle.set_xalign(0)
        page.pack_start(self.operation_subtitle, False, False, 0)

        self.operation_progress = Gtk.ProgressBar()
        self.operation_progress.set_name("operation-progress")
        self.operation_progress.set_show_text(True)
        page.pack_start(self.operation_progress, False, False, 0)

        operation_scroll = Gtk.ScrolledWindow()
        operation_scroll.set_name("operation-scroll")
        operation_scroll.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC)
        operation_scroll.set_overlay_scrolling(False)

        self.operation_log = Gtk.TextView()
        self.operation_log.set_name("operation-log")
        self.operation_log.set_editable(False)
        self.operation_log.set_cursor_visible(False)
        self.operation_log.set_wrap_mode(Gtk.WrapMode.WORD_CHAR)
        self.operation_log.set_left_margin(9)
        self.operation_log.set_right_margin(9)
        self.operation_log.set_top_margin(7)
        self.operation_log.set_bottom_margin(7)
        operation_scroll.add(self.operation_log)
        page.pack_start(operation_scroll, True, True, 0)

        result_line = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        self.operation_result = Gtk.Label()
        self.operation_result.set_name("operation-result")
        self.operation_result.set_xalign(0)
        result_line.pack_start(self.operation_result, True, True, 0)

        self.return_button = Gtk.Button(label="Volver al catálogo")
        self.return_button.set_name("return-button")
        self.return_button.set_size_request(170, 40)
        self.return_button.set_sensitive(False)
        self.return_button.connect("clicked", self.return_to_catalog)
        result_line.pack_end(self.return_button, False, False, 0)
        page.pack_end(result_line, False, False, 0)
        return page

    def select_category(self, _button, name):
        self.category = name
        for category, button in self.category_buttons.items():
            context = button.get_style_context()
            if category == name:
                context.add_class("category-active")
            else:
                context.remove_class("category-active")
        self.render_catalog()

    def refresh_status(self, *_args):
        try:
            with open(STATE_FILE, encoding="utf-8") as state:
                self.managed = {
                    line.strip()
                    for line in state
                    if line.strip()
                }
        except (FileNotFoundError, PermissionError, OSError):
            self.managed = set()

        packages = [item[2] for item in CATALOG]
        command = [
            "dpkg-query",
            "-W",
            "-f=${binary:Package}\t${db:Status-Status}\n",
            *packages,
        ]
        try:
            result = subprocess.run(
                command,
                text=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                check=False,
                timeout=15,
            )
            installed = set()
            for line in result.stdout.splitlines():
                parts = line.split("\t", 1)
                if len(parts) == 2 and parts[1] == "installed":
                    installed.add(parts[0].split(":", 1)[0])
            self.installed = installed
            self.status.set_text(
                f"{len(installed)} instaladas · "
                f"{len(self.managed & installed)} administradas por Tienda Q8"
            )
            logging.info("Estado actualizado: %d instaladas", len(installed))
        except Exception as error:
            logging.exception("No se pudo consultar dpkg")
            self.status.set_text("No se pudo consultar el estado de los paquetes")
        self.render_catalog()

    def render_catalog(self):
        for child in self.list_box.get_children():
            self.list_box.remove(child)

        query = self.search.get_text().strip().casefold()
        visible = []
        for item in CATALOG:
            category, name, package, description, protected = item
            if self.category != "Todas" and category != self.category:
                continue
            haystack = f"{name} {package} {description}".casefold()
            if query and query not in haystack:
                continue
            visible.append(item)

        for item in visible:
            self.list_box.pack_start(self.build_app_card(item), False, False, 0)

        if not visible:
            empty = Gtk.Label(label="No se encontraron aplicaciones")
            empty.set_name("store-subtitle")
            empty.set_margin_top(45)
            self.list_box.pack_start(empty, False, False, 0)

        self.result_count.set_text(f"{len(visible)} aplicaciones")
        self.list_box.show_all()

    def build_app_card(self, item):
        category, name, package, description, protected = item
        installed = package in self.installed
        managed = package in self.managed

        card = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        card.set_name("app-card")
        card.set_size_request(-1, 72)

        icon_name = dict(CATEGORIES).get(category, "application-x-executable")
        icon = Gtk.Image.new_from_icon_name(icon_name, Gtk.IconSize.DIALOG)
        icon.set_pixel_size(38)
        card.pack_start(icon, False, False, 3)

        text = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=2)
        text.set_valign(Gtk.Align.CENTER)

        title = Gtk.Label(label=name)
        title.set_name("app-name")
        title.set_xalign(0)
        text.pack_start(title, False, False, 0)

        description_label = Gtk.Label(label=description)
        description_label.set_name("app-description")
        description_label.set_xalign(0)
        description_label.set_ellipsize(3)
        text.pack_start(description_label, False, False, 0)

        package_label = Gtk.Label(label=package)
        package_label.set_name("package-name")
        package_label.set_xalign(0)
        text.pack_start(package_label, False, False, 0)
        card.pack_start(text, True, True, 0)

        action_column = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=3)
        action_column.set_valign(Gtk.Align.CENTER)

        if installed and (protected or not managed):
            state_text = "INSTALADO · PROTEGIDO"
            button_text = "Protegida"
            state_name = "installed-state"
            action_name = None
        elif installed:
            state_text = "INSTALADO · TIENDA Q8"
            button_text = "Desinstalar"
            state_name = "installed-state"
            action_name = "remove"
        else:
            state_text = "NO INSTALADO · ARMHF"
            button_text = "Instalar"
            state_name = "available-state"
            action_name = "install"

        state = Gtk.Label(label=state_text)
        state.set_name(state_name)
        action_column.pack_start(state, False, False, 0)

        action = Gtk.Button(label=button_text)
        action.get_style_context().add_class("action-button")
        action.set_sensitive(action_name is not None and not self.operation_running)
        if action_name is None:
            action.set_tooltip_text("Aplicación protegida contra desinstalación")
        else:
            action.connect(
                "clicked",
                self.request_package_action,
                action_name,
                item,
            )
        action_column.pack_start(action, False, False, 0)
        card.pack_end(action_column, False, False, 2)
        return card

    def confirmation(self, title, message, confirm_label):
        dialog = Gtk.Dialog(transient_for=self, modal=True)
        dialog.set_decorated(False)
        dialog.set_default_size(470, 210)
        dialog.set_position(Gtk.WindowPosition.CENTER_ON_PARENT)

        content = dialog.get_content_area()
        content.set_border_width(18)
        content.set_spacing(12)

        heading = Gtk.Label()
        heading.set_markup(f"<span size='large' weight='bold'>{title}</span>")
        heading.set_xalign(0)
        content.pack_start(heading, False, False, 0)

        detail = Gtk.Label(label=message)
        detail.set_xalign(0)
        detail.set_line_wrap(True)
        content.pack_start(detail, True, True, 0)

        cancel = dialog.add_button("Cancelar", Gtk.ResponseType.CANCEL)
        cancel.get_style_context().add_class("action-button")
        confirm = dialog.add_button(confirm_label, Gtk.ResponseType.OK)
        confirm.get_style_context().add_class("action-button")
        confirm.set_name("return-button")
        dialog.set_default_response(Gtk.ResponseType.CANCEL)
        dialog.show_all()
        response = dialog.run()
        dialog.destroy()
        return response == Gtk.ResponseType.OK

    def request_update(self, *_args):
        if self.operation_running:
            return
        accepted = self.confirmation(
            "ACTUALIZAR INFORMACIÓN APT",
            "Se descargarán las listas actuales de los repositorios. "
            "No se actualizará el sistema ni sus paquetes.",
            "Actualizar",
        )
        if accepted:
            self.start_operation("update", None, "Actualizando información de paquetes")

    def request_package_action(self, _button, action, item):
        if self.operation_running:
            return
        _category, name, package, _description, _protected = item
        if action == "install":
            title = "INSTALAR APLICACIÓN"
            message = (
                f"Se instalará {name} ({package}) y solamente sus "
                "dependencias necesarias. No se actualizarán otros paquetes."
            )
            confirm_label = "Instalar"
            operation_title = f"Instalando {name}"
        else:
            title = "DESINSTALAR APLICACIÓN"
            message = (
                f"Se quitará {name} ({package}). La operación será bloqueada "
                "si intenta afectar cualquier otro paquete."
            )
            confirm_label = "Desinstalar"
            operation_title = f"Desinstalando {name}"

        if self.confirmation(title, message, confirm_label):
            self.start_operation(action, package, operation_title)

    def start_operation(self, action, package, title):
        self.operation_running = True
        self.refresh_button.set_sensitive(False)
        self.update_button.set_sensitive(False)
        self.close_button.set_sensitive(False)
        self.return_button.set_sensitive(False)
        self.operation_title.set_text(title.upper())
        self.operation_subtitle.set_text(
            "No cierres Tienda Q8 mientras esta operación esté en curso."
        )
        self.operation_result.set_text("Operación en curso…")
        self.operation_progress.set_fraction(0.0)
        self.operation_progress.set_text("Trabajando…")
        self.operation_log.get_buffer().set_text("")
        self.main_stack.set_visible_child_name("operation")
        GLib.timeout_add(120, self.pulse_operation)

        thread = threading.Thread(
            target=self.run_helper,
            args=(action, package),
            daemon=True,
        )
        thread.start()

    def pulse_operation(self):
        if not self.operation_running:
            return False
        self.operation_progress.pulse()
        return True

    def append_operation_output(self, text):
        buffer = self.operation_log.get_buffer()
        end = buffer.get_end_iter()
        buffer.insert(end, text)
        mark = buffer.create_mark(None, buffer.get_end_iter(), False)
        self.operation_log.scroll_mark_onscreen(mark)
        buffer.delete_mark(mark)
        return False

    def run_helper(self, action, package):
        command = ["sudo", "-n", HELPER, action]
        if package is not None:
            command.append(package)

        try:
            process = subprocess.Popen(
                command,
                text=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                bufsize=1,
                errors="replace",
            )
            if process.stdout is not None:
                for line in process.stdout:
                    logging.info("APT: %s", line.rstrip())
                    GLib.idle_add(self.append_operation_output, line)
            return_code = process.wait()
        except Exception as error:
            logging.exception("No se pudo ejecutar el ayudante APT")
            GLib.idle_add(
                self.append_operation_output,
                f"ERROR: {error}\n",
            )
            return_code = 127

        GLib.idle_add(self.finish_operation, return_code, action, package)

    def finish_operation(self, return_code, action, package):
        self.operation_running = False
        self.refresh_button.set_sensitive(True)
        self.update_button.set_sensitive(True)
        self.close_button.set_sensitive(True)
        self.return_button.set_sensitive(True)

        if return_code == 0:
            self.operation_progress.set_fraction(1.0)
            self.operation_progress.set_text("Completado")
            self.operation_result.set_text("✓ Operación completada correctamente")
            self.status.set_text("Última operación completada correctamente")
        else:
            self.operation_progress.set_fraction(0.0)
            self.operation_progress.set_text("Error")
            self.operation_result.set_text(
                f"Error en la operación · código {return_code}"
            )
            self.status.set_text("La última operación terminó con un error")

        logging.info(
            "Operación finalizada: action=%s package=%s code=%s",
            action,
            package,
            return_code,
        )
        self.refresh_status()
        return False

    def return_to_catalog(self, *_args):
        if not self.operation_running:
            self.main_stack.set_visible_child_name("catalog")
            self.render_catalog()

    def on_delete_event(self, *_args):
        if self.operation_running:
            self.operation_result.set_text(
                "Esperá a que termine la operación antes de cerrar."
            )
            return True
        return False


def acquire_single_instance():
    lock_path = f"/tmp/tienda-q8-{os.getuid()}.lock"
    lock = open(lock_path, "w", encoding="utf-8")
    try:
        fcntl.flock(lock.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        return None
    return lock


def main():
    lock = acquire_single_instance()
    if lock is None:
        logging.info("Tienda Q8 ya estaba abierta")
        return 0

    window = TiendaQ8()
    window.show_all()
    Gtk.main()
    return 0


if __name__ == "__main__":
    sys.exit(main())
