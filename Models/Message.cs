using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;

namespace habitat_aspnet_sample.Models
{
    public class MessageContext : DbContext
    {
        public MessageContext(DbContextOptions<MessageContext> options)
            : base(options)
        { }

        public DbSet<Message> Messages { get; set; }
    }

    public class Message
    {
        public int MessageId { get; set; }
        public string MessageText { get; set; }
    }
}
