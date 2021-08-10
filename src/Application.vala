/*
* Copyright © 2018–2021 Cassidy James Blaede (https://cassidyjames.com)
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
    private const string GTK_DARK = "gtk_application_prefer_dark_theme";

    public static GLib.Settings settings;
    public static MiniWindow mini_window;
    public static MainWindow main_window;

    private uint configure_id;
    private const uint CONFIGURE_ID_TIMEOUT = 100;

    public Palette () {
        Object (application_id: "com.github.cassidyjames.palette",
        flags: ApplicationFlags.FLAGS_NONE);
    }

    public static Palette _instance = null;
    public static Palette instance {
        get {
            if (_instance == null) {
                _instance = new Palette ();
            }
            return _instance;
        }
    }

    static construct {
        settings = new Settings ("com.github.cassidyjames.palette");
    }

    protected override void activate () {
        if (get_windows ().length () > 0) {
            get_windows ().data.present ();
            return;
        }

        // Handle quitting
        var quit_action = new SimpleAction ("quit", null);

        add_action (quit_action);
        set_accels_for_action ("app.quit", {"Escape"});

        quit_action.activate.connect (() => {
            if (main_window != null) {
                main_window.destroy ();
            }

            if (mini_window != null) {
                mini_window.destroy ();
            }
        });

        unowned var gtk_settings = Gtk.Settings.get_default ();
        unowned var granite_settings = Granite.Settings.get_default ();

        gtk_settings.gtk_cursor_theme_name = "elementary";
        gtk_settings.gtk_icon_theme_name = "elementary";
        gtk_settings.gtk_theme_name = "io.elementary.stylesheet.slate";

        gtk_settings.gtk_application_prefer_dark_theme = (
            granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK
        );

        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme = (
                granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK
            );
        });

        // Set up main window
        main_window = new MainWindow (this);
        main_window.configure_event.connect (() => {
            if (configure_id != 0) {
                GLib.Source.remove (configure_id);
            }

            configure_id = Timeout.add (CONFIGURE_ID_TIMEOUT, () => {
                configure_id = 0;
                save_window_geometry (main_window);

                return false;
            });

            return false;
        });
        main_window.destroy.connect (() => {
            quit_action.activate (null);
        });


        // Set up mini window
        mini_window = new MiniWindow (this);
        mini_window.configure_event.connect (() => {
            if (configure_id != 0) {
                GLib.Source.remove (configure_id);
            }

            configure_id = Timeout.add (CONFIGURE_ID_TIMEOUT, () => {
                configure_id = 0;
                save_window_geometry (mini_window, "mini-position");

                return false;
            });

            return false;
        });
        mini_window.destroy.connect (() => {
            quit_action.activate (null);
        });

        // Show the correct window
        if (settings.get_boolean ("mini-mode")) {
            mini_window.show_all ();
        } else {
            main_window.show_all ();
        }

        // CSS provider
        var provider = new Gtk.CssProvider ();
        provider.load_from_resource ("/com/github/cassidyjames/palette/Application.css");
        Gtk.StyleContext.add_provider_for_screen (
            Gdk.Screen.get_default (),
            provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        );
    }

    private void save_window_geometry (Gtk.Window window, string key = "window-position") {
        int root_x, root_y;
        window.get_position (out root_x, out root_y);
        Palette.settings.set_value (key, new int[] { root_x, root_y });
    }

    private static int main (string[] args) {
        Gtk.init (ref args);

        var app = new Palette ();
        return app.run (args);
    }
}
