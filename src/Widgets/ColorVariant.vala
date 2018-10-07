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

public class ColorVariant : Gtk.Button {
    public Color color { get; construct; }
    public int variant { get; construct; }
    public Gtk.Popover color_menu { get; construct; }
    public Granite.ModeSwitch toggle { get; construct; }

    public string to_copy;

    public ColorVariant (Color color, int variant, Gtk.Popover color_menu, Granite.ModeSwitch toggle) {
        Object (
            color: color,
            color_menu: color_menu,
            height_request: 48,
            hexpand: true,
            toggle: toggle,
            variant: variant
        );
    }

    construct {
        get_style_context ().add_class ("%s-%i".printf (
            color.style_class (),
            variant
        ));

        string hex = color.hex ()[variant];
        to_copy = hex;
        tooltip_text = _("Copy %s to clipboard").printf (to_copy);

        var variant_label = new Gtk.Label ("<b>%i</b>".printf (variant));
        variant_label.expand = true;
        variant_label.halign = Gtk.Align.START;
        variant_label.use_markup = true;
        variant_label.valign = Gtk.Align.CENTER;

        var hex_label = new Gtk.Label (hex);
        hex_label.expand = true;
        hex_label.halign = Gtk.Align.END;
        hex_label.valign = Gtk.Align.CENTER;
        hex_label.get_style_context ().add_class ("monospace");

        // Build CSS color constant variable name
        string caps = color.to_string ().replace ("COLOR_", "");
        string css_var = "@%s_%i".printf (caps, variant);

        var const_label = new Gtk.Label (css_var);
        const_label.expand = true;
        const_label.halign = Gtk.Align.END;
        const_label.valign = Gtk.Align.CENTER;
        const_label.get_style_context ().add_class ("monospace");

        var grid = new Gtk.Grid ();
        grid.attach (variant_label, 0, 0);
        grid.attach (hex_label,     1, 0);
        grid.attach (const_label,   2, 0);

        this.add (grid);

        toggle.notify["active"].connect (() => {
            if (toggle.active) {
                to_copy = css_var;
            } else {
                to_copy = hex;
            }

            tooltip_text = _("Copy %s to clipboard").printf (to_copy);
        });

        toggle.bind_property ("active", const_label, "visible");
        toggle.bind_property ("active", hex_label, "visible", BindingFlags.INVERT_BOOLEAN);

        this.clicked.connect (() => {
            Gtk.Clipboard.get_default (this.get_display ()).set_text (to_copy, -1);
            color_menu.hide ();
        });
    }
}

