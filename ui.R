library(shiny)
library(magrittr)
library(ape)
library(ggtree)
library(gridExtra)
library(cowplot)
library(shinyBS)
library(shinyLP)
library(shinythemes)

#mammals <- read.tree("mammal_raxml_bmc_paper_data/alltrees.tre")

#get species list
#species <- sort(as.character(mammals[[1]]["tip.label"][[1]]))

#set root for each tree
#for (i in 1:length(mammals)){
#  mammals[i]<-root(mammals[i], outgroup = "Opossum", resolve.root = TRUE)
#}

# Define UI for application
shinyUI(
  
  # Include a fliudPage above the navbar to incorporate a icon in the header
  # Source: http://stackoverflow.com/a/24764483
  fluidPage(
    
    div(style="padding: 1px 0px; width: '100%'",
        titlePanel(
          title="", windowTitle="LandscapR: Comparing phylogenies from different datasets"
        )
    ),
    
    navbarPage(title = "LandscapR: Comparing phylogenies from different datasets",
               inverse = F, # for diff color view
               theme = shinytheme("united"),
               
               tabPanel("Landing Page", icon = icon("home"),
                        
                        jumbotron(div(img(src="LandscapR.png"))),
                        fluidRow(
                          column(6, panel_div(class_type = "primary", panel_title = "Directions",
                                              content = "How to use the app")),
                          column(6, panel_div("success", "Application Maintainers",
                                              HTML("Email Me: <a href='mailto:jasmine.dumas@gmail.com?Subject=Shiny%20Help' target='_top'>Jasmine Dumas</a>")))
                        ),  # end of fluidRow
                        fluidRow(
                          column(6, panel_div("info", "App Status", "Include text with status, version and updates")),
                          column(6, panel_div("danger", "Security and License", "Copyright 2016")),
                          
                          #### FAVICON TAGS SECTION ####
                          tags$head(tags$link(rel="shortcut icon", href="favicon.ico"))
                          
                        )  # end of fluidRow
               ), #end tabpanel 1
               
               tabPanel("App", icon = icon("cog"),          
                        # Sidebar with a slider input for number of bins 
                        fluidRow(
                          column(4,
                                 content = 'This app allows you to compare phylogenies generated from different datasets.
                                 Use the default datasets of mammals (from Schwartz et al. 2015) or upload your own.
                                 Select an outgroup to root the tree.
                                 Given a selection of two species, the app will highlight the smallest clade containing
                                 those two species.',
                                 
                                 fileInput("file", h3("Upload your own trees")),
                                 
                                 uiOutput("outgroup"),# from objects created in server
                                 
                                 uiOutput("select"),#add selectinput boxs
                                 
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
               )  #end tabpanel 2
    ) #end navbarpage
  ) #end fluidpage
) #end shinyui