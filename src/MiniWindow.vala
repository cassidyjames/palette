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

public class MiniWindow : Gtk.Window {
    public MiniWindow (Gtk.Application application) {
        Object (
            application: application,
            icon_name: "com.github.cassidyjames.palette",
            resizable: false,
            skip_taskbar_hint: true
        );
    }

    construct {
        stick ();
        set_keep_above (true);

        var restore_button = new Gtk.Button.from_icon_name ("window-pop-out-symbolic", Gtk.IconSize.MENU);
        restore_button.halign = Gtk.Align.CENTER;
        restore_button.tooltip_text = _("Windowed mode");
        restore_button.valign = Gtk.Align.CENTER;

        var restore_button_context = restore_button.get_style_context ();
        restore_button_context.add_class ("titlebutton");
        restore_button_context.remove_class ("image-button");

        var header = new Gtk.HeaderBar ();
        header.has_subtitle = false;
        header.set_custom_title (restore_button);
        header.show_close_button = false;

        var header_context = header.get_style_context ();
        header_context.add_class ("titlebar");
        header_context.add_class ("default-decoration");
        header_context.add_class (Gtk.STYLE_CLASS_FLAT);

        var strawberry_button = new ColorButton (Color.STRAWBERRY, 32);
        var orange_button = new ColorButton (Color.ORANGE, 32);
        var banana_button = new ColorButton (Color.BANANA, 32);
        var lime_button = new ColorButton (Color.LIME, 32);
        var blueberry_button = new ColorButton (Color.BLUEBERRY, 32);
        var grape_button = new ColorButton (Color.GRAPE, 32);
        var cocoa_button = new ColorButton (Color.COCOA, 32);
        var silver_button = new ColorButton (Color.SILVER, 32);
        var slate_button = new ColorButton (Color.SLATE, 32);
        var black_button = new ColorButton (Color.BLACK, 32);

        var mini_layout = new Gtk.Grid ();
        mini_layout.row_spacing = mini_layout.margin_bottom = 12;
        mini_layout.margin_top = mini_layout.margin_start = mini_layout.margin_end = 6;

        int row = 0;
        mini_layout.attach (strawberry_button, 0, row++);
        mini_layout.attach (orange_button,     0, row++);
        mini_layout.attach (banana_button,     0, row++);
        mini_layout.attach (lime_button,       0, row++);
        mini_layout.attach (blueberry_button,  0, row++);
        mini_layout.attach (grape_button,      0, row++);
        mini_layout.attach (cocoa_button,      0, row++);
        mini_layout.attach (silver_button,     0, row++);
        mini_layout.attach (slate_button,      0, row++);
        mini_layout.attach (black_button,      0, row++);

        var context = get_style_context ();
        context.add_class ("palette");
        context.add_class ("rounded");
        context.add_class ("flat");

        set_titlebar (header);
        add (mini_layout);

        restore_button.clicked.connect (() => {
            Palette.settings.set_boolean ("mini-mode", false);
            Palette.main_window.show_all ();

            hide ();
        });
    }

    public override void realize () {
        base.realize ();
        int32 x = 0, y = 0;

        var mini_position = Palette.settings.get_value ("mini-position");
        if (mini_position.n_children () == 2) {
            x = (int32) mini_position.get_child_value (0);
            y = (int32) mini_position.get_child_value (1);
        } else {
            int width, height;
            get_size (out width, out height);

            var screen = Gdk.Screen.get_default ();
            var display = screen.get_display ();
            var monitor = display.get_primary_monitor ();
            var geometry = monitor.geometry;
            y = geometry.height / 2 - height / 2;
        }

        move (x, y);
    }
}

