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

public class MainWindow : Gtk.Window {
    public MainWindow (Gtk.Application application) {
        Object (
            application: application,
            icon_name: "com.github.cassidyjames.palette",
            resizable: false,
            title: _("Palette")
        );
    }

    construct {
        var mini_button = new Gtk.Button.from_icon_name ("window-minimize-symbolic", Gtk.IconSize.MENU);
        mini_button.tooltip_text = _("Mini mode");
        mini_button.valign = Gtk.Align.CENTER;

        var mini_button_context = mini_button.get_style_context ();
        mini_button_context.add_class ("titlebutton");
        mini_button_context.remove_class ("image-button");

        var header = new Gtk.HeaderBar ();
        header.show_close_button = true;
        header.pack_end (mini_button);

        var header_context = header.get_style_context ();
        header_context.add_class ("titlebar");
        header_context.add_class ("default-decoration");
        header_context.add_class (Gtk.STYLE_CLASS_FLAT);

        var strawberry_button = new ColorButton (Color.STRAWBERRY);
        var orange_button = new ColorButton (Color.ORANGE);
        var banana_button = new ColorButton (Color.BANANA);
        var lime_button = new ColorButton (Color.LIME);
        var mint_button = new ColorButton (Color.MINT);
        var blueberry_button = new ColorButton (Color.BLUEBERRY);
        var grape_button = new ColorButton (Color.GRAPE);
        var bubblegum_button = new ColorButton (Color.BUBBLEGUM);
        var cocoa_button = new ColorButton (Color.COCOA);
        var silver_button = new ColorButton (Color.SILVER);
        var slate_button = new ColorButton (Color.SLATE);
        var black_button = new ColorButton (Color.BLACK);

        var main_layout = new Gtk.Grid ();
        main_layout.column_spacing = main_layout.row_spacing = 12;
        main_layout.margin_bottom = main_layout.margin_start = main_layout.margin_end = 12;

        main_layout.attach (strawberry_button, 0, 0);
        main_layout.attach (orange_button, 1, 0);
        main_layout.attach (banana_button, 2, 0);
        main_layout.attach (lime_button, 3, 0);

        main_layout.attach (mint_button, 0, 1);
        main_layout.attach (blueberry_button, 1, 1);
        main_layout.attach (grape_button, 2, 1);
        main_layout.attach (bubblegum_button, 3, 1);

        main_layout.attach (cocoa_button, 0, 2);
        main_layout.attach (silver_button, 1, 2);
        main_layout.attach (slate_button, 2, 2);
        main_layout.attach (black_button, 3, 2);

        var context = get_style_context ();
        context.add_class ("palette");
        context.add_class ("rounded");
        context.add_class ("flat");

        var gtk_settings = Gtk.Settings.get_default ();
        if (gtk_settings.gtk_application_prefer_dark_theme) {
            context.add_class ("dark");
        }

        set_titlebar (header);
        add (main_layout);

        mini_button.clicked.connect (() => {
            Palette.settings.set_boolean ("mini-mode", true);

            Palette.mini_window.show_all ();

            hide ();
        });
    }

    public override void realize () {
        base.realize ();

        var main_position = Palette.settings.get_value ("window-position");
        if (main_position.n_children () == 2) {
            var x = (int32) main_position.get_child_value (0);
            var y = (int32) main_position.get_child_value (1);

            move (x, y);
        } else {
            window_position = Gtk.WindowPosition.CENTER;
        }
    }
}
