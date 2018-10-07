/*
* Copyright (c) 2018 Cassidy James Blaede (https://cassidyjames.com)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Cassidy James Blaede <c@ssidyjam.es>
*/

public class Palette : Gtk.Application {
    public static GLib.Settings settings;
    private uint configure_id;
    public const uint CONFIGURE_ID_TIMEOUT = 100;  // 100ms

    public Palette () {
        Object (application_id: "com.github.cassidyjames.palette",
        flags: ApplicationFlags.FLAGS_NONE);
    }

    static construct {
        settings = new Settings ("com.github.cassidyjames.palette");
    }

    protected override void activate () {
        if (get_windows ().length () > 0) {
            get_windows ().data.present ();
            return;
        }

        var app_window = new MainWindow (this);

        var position = settings.get_value ("window-position");
        if (position.n_children () == 2) {
            var x = (int32) position.get_child_value (0);
            var y = (int32) position.get_child_value (1);

            app_window.move (x, y);
        }

        app_window.configure_event.connect (() => {
            if (configure_id != 0) {
                GLib.Source.remove (configure_id);
            }

            configure_id = Timeout.add (CONFIGURE_ID_TIMEOUT, () => {
                configure_id = 0;
                save_window_geometry (app_window);

                return false;
            });

            return false;
        });

        app_window.show_all ();

        var quit_action = new SimpleAction ("quit", null);

        add_action (quit_action);
        set_accels_for_action ("app.quit", {"Escape"});

        var provider = new Gtk.CssProvider ();
        provider.load_from_resource ("/com/github/cassidyjames/palette/Application.css");
        Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        quit_action.activate.connect (() => {
            if (app_window != null) {
                app_window.destroy ();
            }
        });
    }

    private void save_window_geometry (Gtk.Window window) {
        int root_x, root_y;
        window.get_position (out root_x, out root_y);
        Palette.settings.set_value ("window-position", new int[] { root_x, root_y });
    }

    private static int main (string[] args) {
        Gtk.init (ref args);

        var app = new Palette ();
        return app.run (args);
    }
}

