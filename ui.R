###     -*- Coding: utf-8 -*-          ###
### Analyste Charles-Edouard Giguere   ###

### Shiny application for the article: correspondance between the
### SANS/SAPS and the PANSS.

### User interface side. 

require(shinyjs)

ui <- pageWithSidebar(

  # App title ----
  headerPanel("SAPS/SANS PANSS SCORE CONVERTER"),

  # Sidebar panel for inputs ----
  sidebarPanel(width = 4,
               fluidRow(
                   column(3,
                          img(src = "26682017.png",width = "100px")
                          ),
                   column(9, h3("PNP LAB"),                         
                          h4("Predictive Neuroimaging in Psychiatry Lab")
                          )
               ),
               selectInput("CORR1",
                           label = "CORRESPONDANCE(CHECK ALL CORRESPONDANCE NEEDED)",
                           multiple = TRUE,
                           choices = c("PANSS_negative => SANS_composite",      
                                       "SANS_composite => PANSS_negative", 
                                       "PANSS_negative => SANS_summary", 
                                       "SANS_summary => PANSS_negative", 
                                       "SANS_summary => SANS_composite", 
                                       "SANS_composite => SANS_summary", 
                                       "PANSS_positive => SAPS_composite", 
                                       "SAPS_composite => PANSS_positive", 
                                       "PANSS_positive => SAPS_summary", 
                                       "SAPS_summary => PANSS_positive", 
                                       "SAPS_summary => SAPS_composite", 
                                       "SAPS_composite => SAPS_summary", 
                                       "PANSS_neg_it8_10_13 => SANS_neg_it8_13",
                                       "SANS_neg_it8_13 => PANSS_neg_it8_10_13",
                                       "PANSS_neg_it9_11 => SANS_neg_it17_22", 
                                       "SANS_neg_it17_22 => PANSS_neg_it9_11", 
                                       "PANSS_neg_it12 => SANS_neg_it25", 
                                       "SANS_neg_it25 => PANSS_neg_it12", 
                                       "PANSS_pos_it1_5_6_7 => SAPS_pos_it_20", 
                                       "SAPS_pos_it_20 => PANSS_pos_it1_5_6_7", 
                                       "PANSS_pos_it2 => SAPS_pos_it_25_34", 
                                       "SAPS_pos_it_25_34 => PANSS_pos_it2", 
                                       "PANSS_pos_it_3 => SAPS_pos_it_7", 
                                       "SAPS_pos_it_7 => PANSS_pos_it_3")),
               checkboxInput("fl",
                             label = "Ignore First line",
                             value = FALSE
               ),
               fileInput("FIN",
                         "INPUT FILE (COLUMNS MUST BE IN ORDER OF CORRESPONDANCE)",
                         accept=c('text/csv',
                                  'text/comma-separated-values,text/plain',
                                  '.csv')
                         ),
               downloadLink("Download", "Download the output file"),
               br(),
               br(),
               br(),
               a("See Manual",href = "https://github.com/pnplab/psych_corr",
                 target = "_blank"),
               actionButton("close",
                            "Fermer")
               ),

  # Main panel for displaying outputs ----
  mainPanel(fluidRow(column(4,
                            fluidRow(tableOutput("ORDER"),
                                     plotOutput("FIG1"),
                                     actionButton("Next", label = "Next plot"),
                                     useShinyjs()
                                     )
                            ),
                     column(8, tableOutput("OUT1"))                     
                     )

            )
)
  


  
