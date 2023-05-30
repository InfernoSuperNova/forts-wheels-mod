Root =
{
    Type = "Control",
    Name = "GXWheelThrottle",
    Style = "Normal",
    Position = { 0, 0, },
    Size = { 0, 0, },
    Children =
    {
        {
            Type = "SliderBar",
            Name = "PropulsionSlider",
            Style = "SliderBar",
            ValIsPercentage = false,
            Static =
            {
                --Texture = "ui/textures/FE-PanelTiny.dds",
                Control =
                {
                    ClipChildren = true,
                    Position = { 230, 480, },
                    Size = { 600, 30, },
                    TabStop = 6,
                    Children =
                    {
                        {
                            Type = "Button",
                            Name = "DownButton",
                            Style = "SliderBar",
                            Static =
                            {
                                Texture = "slider-arrow-left",
                                Control =
                                {
                                    Position = { 15, 9, },
                                    Size = { 24, 24, },
                                    Anchor = 3,
                                },
                            },
                        },
                        {
                            Type = "Button",
                            Name = "UpButton",
                            Style = "SliderBar",
                            Static =
                            {
                                Texture = "slider-arrow-right",
                                Control =
                                {
                                    Position = { 132, 9, },
                                    Size = { 24, 24, },
                                    Anchor = 2,
                                },
                            },
                        },
                        {
                            Type = "Button",
                            Name = "SliderTrack",
                            Style = "Normal",
                            Static =
                            {
                                Texture = "ui/textures/SliderTrack.dds",
                                Control =
                                {
                                    Position = { 15, 9, },
                                    Size = { 117, 24, },
                                    Anchor = 2,
                                },
                            },
                        },
                        {
                            Type = "Button",
                            Name = "MiddleMarker",
                            Style = "Normal",
                            Static =
                            {
                                Texture = "ui/textures/SliderBar.dds",
                                Control =
                                {
                                    Position = { 273.5, 15, },
                                    Size = { 6, 36, },
                                    Anchor = 8,
                                },
                            },
                        },
                        {
                            Type = "Button",
                            Name = "SliderBar",
                            Style = "SliderBar",
                            Static =
                            {
                                Texture = "ui/textures/SliderBar.dds",
                                Control =
                                {
                                    Position = { 129, 9, },
                                    Size = { 12, 24, },
                                    Anchor = 8,
                                },
                            },
                        },
                        -- {
                        --     Type = "Text",
                        --     Name = "ValueText",
                        --     Style = "Normal",
                        --     Text = "0%",
                        --     Control =
                        --     {
                        --         Position = { 197, 9, },
                        --         Size = { 45.14, 12, },
                        --         Anchor = 3,
                        --     },
                        -- },
                    },
                },
            },
        },
    }
}
