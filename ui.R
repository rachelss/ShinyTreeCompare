library(shiny)
library(magrittr)
library(ape)
library(ggtree)
library(gridExtra)
library(cowplot)
library(shinyBS)
library(shinyLP)
library(shinythemes)

shinyUI(
  
  # Include a fliudPage above the navbar to incorporate a icon in the header
  # Source: http://stackoverflow.com/a/24764483
  fluidPage(
    
    div(style="padding: 1px 0px; width: '100%'",
        titlePanel(title="LandscapR", windowTitle="LandscapR: Comparing phylogenies from different datasets")
    ), #end div
    
    navbarPage(title = "Exploring the landscape of phylogenetic trees from different datasets",
               inverse = F, # for diff color view
               theme = shinytheme("superhero"),
               
               tabPanel("Landing Page", icon = icon("home"),
                        
                        fluidRow(
                          column(12, align="center",
                                 div(style="display: inline-block; width: 100% ;",
                                     img(src="LandscapR2.png",width="100%"))
                          )
                        ),
                        
                        fluidRow(
                          column(6,
                                 actionButton("tabBut", "Motivational Slides")),
                          column(6, panel_div("success", "Contact",
                                              HTML("Email Me: <a href='mailto:rsschwartz@uri.edu?Subject=LandscapR%20Help' target='_top'>Rachel Schwartz</a>")))
                        ),  # end of fluidRow
                        
                        fluidRow(
                          column(6, panel_div("info", "App Status", "Include text with status, version and updates")),
                          column(6, panel_div("danger", "License and credit", "Copyright 2019. 
                                              This Shiny App is built on ShinyLP and ggtree"))
                          
                        ),  # end of fluidRow
                        
                        bsModal("modalExample", "Motivational Slides", "tabBut", size = "large" ,
                                #p("Additional text and widgets can be added in these modal boxes. Video plays in chrome browser"),
                                iframe(width = "560", height = "315", 
                                       url_link = "https://docs.google.com/presentation/d/e/2PACX-1vQoNZpY-M3XvzVEX0EkNPhUlyEpeaJONxW1aLe__Jk2FX-dQhaKRFJNk_7j1C-zI0uP_8zFIX9ua5UR/embed?start=true&loop=false&delayms=5000")
                        )  #end bsmodal
                        #OPEN IN BROWSER TO VIEW SLIDES
                        #have to publish slides to web before they'll be viewable https://en.support.wordpress.com/google-docs/
               ), #end tabpanel 1 (landing)
               
               tabPanel("Exercise 1", icon = icon("cog"),
                        fluidRow(
                          column(12,
                                 p("Using the example datasets to answer the following questions.")
                          )
                        ),
                        fluidRow(
                           column(12, 
                                   panel_div("info", "1. How closely are Armadillos related to Aardvarks?", 
                                             "Select Wallaby as the outgroup.
                                              The highlighted species in each tree form a clade showing all the species
                                             identified in a clade for the most recent common ancestor (MRCA) of 
                                             Armadillos and Aardvarks. 
                                             What is similar and different among the trees?")
                                  )
                        ), #end row
                        fluidRow(
                          column(6,
                               actionButton("solutionBut", "Solution 1")
                          )
                        ),
                        bsModal("answer1", "Solution to Q 1", "solutionBut", size = "large" ,
                                p("For m2, m3, and m4, these two species are found in a
                                             clade containing ")
                        )  #end bsmodal answer1
               ),  #end tabpanel 2 (ex 1)
               
               tabPanel("App", icon = icon("cog"),          
                        # Sidebar with a slider input for number of bins 
                        fluidRow(
                          column(4,
                                 p("This app allows you to compare phylogenies generated from different datasets.
                                 Use the default datasets of mammals (from Schwartz et al. 2015) or upload your own.
                                 Select an outgroup to root the tree.
                                 Given a selection of two species, the app will highlight the smallest clade containing
                                 those two species."),
                                 
                                 fileInput("file", h3("Upload your own trees")),
                                 
                                 uiOutput("outgroup"), # from objects created in server
                                 
                                 uiOutput("select"), #add selectinput boxs
                                 
                                 selectInput("hilite", h3("Select which to highlight"), 
                                             choices = c("Clade","Species"),selected = "Clade"
                                 ),
                                 radioButtons("brlens", h3("Show Branch Lengths"),
                                              choices = list("Brlens" = 1, "Cladogram" = 2),
                                              selected = 1
                                 )
                                 
                          ),  #end sidebar column
                          
                          column(8,
                                 plotOutput("phyloPlot", height="auto")
                          )  #end center column
                        ) #end single fluidrow
               ),  #end tabpanel 3 (app)
               
               tabPanel("Example data", icon = icon("cog"),
                        fluidRow(
                          column(12,
                                 p("The example phylogenies come from Schwartz et al. 2015.
                                   Phylogenies were estimated from datasets created with the SISRS software 
                                   (https://github.com/rachelss/SISRS).
                                   The datasets have between 1 and 15 species missing per site.
                                   Phylogenies were estimated from concatenated variable sites
                                   using Maximum Likelihood in ...")
                          )
                        )
               )  #end tabpanel 2 (ex 1)

    ) #end navbarpage
  ) #end fluidpage
) #end shinyui