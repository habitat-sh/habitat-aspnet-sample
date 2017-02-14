using System;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;
using habitat_aspnet_sample.Models;

namespace habitataspnetsample.Migrations
{
    [DbContext(typeof(MessageContext))]
    [Migration("20170213203555_first")]
    partial class first
    {
        protected override void BuildTargetModel(ModelBuilder modelBuilder)
        {
            modelBuilder
                .HasAnnotation("ProductVersion", "1.1.0-rtm-22752");

            modelBuilder.Entity("habitat_aspnet_sample.Models.Message", b =>
                {
                    b.Property<int>("MessageId")
                        .ValueGeneratedOnAdd();

                    b.Property<string>("MessageText");

                    b.HasKey("MessageId");

                    b.ToTable("Messages");
                });
        }
    }
}
