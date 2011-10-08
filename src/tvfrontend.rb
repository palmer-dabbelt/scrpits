require 'gtk2'

WINDOW_WIDTH = `xdpyinfo | grep dimen`.split(":")[1].split("pixels")[0].split("x")[0].to_i
WINDOW_HEIGHT = `xdpyinfo | grep dimen`.split(":")[1].split("pixels")[0].split("x")[1].to_i

GTK_TABLE_HEIGHT = 2
GTK_TABLE_WIDTH = 2

@window = Gtk::Window.new
@window.border_width = 10
@window.set_default_size(WINDOW_WIDTH, WINDOW_HEIGHT)

#code for destruction
@window.signal_connect("destroy"){
	Gtk.main_quit	
}

#table-based layout
@table = Gtk::Table.new(GTK_TABLE_HEIGHT, GTK_TABLE_WIDTH, true)
@table.column_spacings = 2
@table.row_spacings = 2

button = Gtk::Button.new("Firefox")
@table.attach_defaults(button, 0, 1, 0, 1)
button.signal_connect("clicked"){`firefox`}

button = Gtk::Button.new("XBMC")
@table.attach_defaults(button, 1, 2, 0, 1)
button.signal_connect("clicked"){`xbmc`}

button = Gtk::Button.new("VirtualBox")
@table.attach_defaults(button, 1, 2, 1, 2)
button.signal_connect("clicked"){`VirtualBox`}

button = Gtk::Button.new("VLC")
@table.attach_defaults(button, 0, 1, 1, 2)
button.signal_connect("clicked"){`vlc`}

@window.add(@table)
@window.show_all

Gtk.main
